/*
Copyright IBM Corp. All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
    "fmt"
    "testing"

    "github.com/hyperledger/fabric/core/chaincode/shim"
)

func checkState(t *testing.T, stub *shim.MockStub, name string, value string) {
    bytes := stub.State[name]
    if bytes == nil {
        fmt.Println("State", name, "failed to get value")
        t.FailNow()
    }
    if string(bytes) != value {
        fmt.Println("State value", name, "was not", value, "as expected")
        fmt.Println(string(bytes))
        t.FailNow()
    }
}

func checkInvokeExpectMessage(t *testing.T, stub *shim.MockStub, args [][]byte, expectedStatus int32, expectedMessage string) {
    res := stub.MockInvoke("1", args)
    if res.Status != expectedStatus {
        fmt.Println("Invoke", args, "failed. Expected another status", string(res.Message))
        t.FailNow()
    }
    if expectedMessage != "" && expectedMessage != string(res.Message){
        fmt.Println("Invoke", args, "failed. Got: ", string(res.Message), "\nExpected: ", expectedMessage)
        t.FailNow()
    }
}

func checkInvoke(t *testing.T, stub *shim.MockStub, args [][]byte, expectedStatus int32) {
    checkInvokeExpectMessage(t, stub, args, expectedStatus, "")
}

func Test_initLedger(t *testing.T) {
    scc := new(SimpleAsset)
    stub := shim.NewMockStub("acc", scc)

    checkInvoke(t, stub, [][]byte{[]byte("initLedger")}, shim.OK)
    checkState(t, stub, "allowedCurrencies", "{\"BTC\":true,\"LTC\":true}")
}

func Test_addAllowedCurrency(t *testing.T) {
    scc := new(SimpleAsset)
    stub := shim.NewMockStub("acc", scc)

    checkInvoke(t, stub, [][]byte{[]byte("initLedger")}, shim.OK)
    // We can't add alredy allowed currency
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("addAllowedCurrency"), []byte("BTC")}, shim.ERROR, "The BTC has been already allowed.")
    checkInvoke(t, stub, [][]byte{[]byte("addAllowedCurrency"), []byte("DGC")}, shim.OK)
    checkState(t, stub, "allowedCurrencies", "{\"BTC\":true,\"DGC\":true,\"LTC\":true}")
}

func Test_removeAllowedCurrency(t *testing.T) {
    scc := new(SimpleAsset)
    stub := shim.NewMockStub("acc", scc)

    checkInvoke(t, stub, [][]byte{[]byte("initLedger")}, shim.OK)
    // We can't remove not absent currency
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("removeAllowedCurrency"), []byte("DGC")}, shim.ERROR, "There is no DGC asset.")
    checkInvoke(t, stub, [][]byte{[]byte("removeAllowedCurrency"), []byte("BTC")}, shim.OK)
    checkState(t, stub, "allowedCurrencies", "{\"LTC\":true}")
}

func Test_createAccount(t *testing.T) {
    scc := new(SimpleAsset)
    stub := shim.NewMockStub("acc", scc)

    checkInvoke(t, stub, [][]byte{[]byte("initLedger")}, shim.OK)
    checkInvoke(t, stub, [][]byte{[]byte("createAccount"), []byte("1")}, shim.OK)
    // We can't create same account twice
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("createAccount"), []byte("1")}, shim.ERROR, "Account already exists")
}

func Test_updateAccountAsset(t *testing.T) {
    scc := new(SimpleAsset)
    stub := shim.NewMockStub("acc", scc)
    BD_ACCOUNT, _ := stub.CreateCompositeKey("1", []string{ACCOUNT_KEY})

    checkInvoke(t, stub, [][]byte{[]byte("initLedger")}, shim.OK)
    checkInvoke(t, stub, [][]byte{[]byte("createAccount"), []byte("1")}, shim.OK)
    // We can't set amount belove zero durin update
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("updateAccountAsset"), []byte("BTC"), []byte("1"), []byte("-10")}, shim.ERROR, "Can't set currency amount belove zero")
    // We can't update not created account
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("updateAccountAsset"), []byte("BTC"), []byte("2"), []byte("10")}, shim.ERROR, "Account does not exist")
    // We can't update with not allowed currency
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("updateAccountAsset"), []byte("DGC"), []byte("1"), []byte("-10")}, shim.ERROR, "There is no DGC asset allowed")

    checkInvoke(t, stub, [][]byte{[]byte("updateAccountAsset"), []byte("BTC"), []byte("1"), []byte("10")}, shim.OK)
    checkState(t, stub, BD_ACCOUNT, "{\"account\":\"1\",\"currency\":{\"BTC\":10}}")

    checkInvoke(t, stub, [][]byte{[]byte("updateAccountAsset"), []byte("BTC"), []byte("1"), []byte("10")}, shim.OK)
    checkState(t, stub, BD_ACCOUNT, "{\"account\":\"1\",\"currency\":{\"BTC\":20}}")

    checkInvoke(t, stub, [][]byte{[]byte("updateAccountAsset"), []byte("BTC"), []byte("1"), []byte("-20")}, shim.OK)
    checkState(t, stub, BD_ACCOUNT, "{\"account\":\"1\",\"currency\":{\"BTC\":0}}")
}

func Test_transferAsset(t *testing.T) {
    scc := new(SimpleAsset)
    stub := shim.NewMockStub("acc", scc)
    BD_ACCOUNT_1, _ := stub.CreateCompositeKey("1", []string{ACCOUNT_KEY})
    BD_ACCOUNT_2, _ := stub.CreateCompositeKey("2", []string{ACCOUNT_KEY})

    checkInvoke(t, stub, [][]byte{[]byte("initLedger")}, shim.OK)
    checkInvoke(t, stub, [][]byte{[]byte("createAccount"), []byte("1")}, shim.OK)
    checkInvoke(t, stub, [][]byte{[]byte("createAccount"), []byte("2")}, shim.OK)
    checkInvoke(t, stub, [][]byte{[]byte("updateAccountAsset"), []byte("BTC"), []byte("1"), []byte("10")}, shim.OK)

    // We can't transfer more then from_account balance
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("transferAsset"), []byte("BTC"), []byte("1"), []byte("2"), []byte("15")}, shim.ERROR, "Not enough balance at from account")
    // We can't transfer to the same account
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("transferAsset"), []byte("BTC"), []byte("1"), []byte("1"), []byte("3")}, shim.ERROR, "Can not transfer the assert: target account is the same as source account.")
    // We cannot transfer not allowed currency
    checkInvokeExpectMessage(t, stub, [][]byte{[]byte("transferAsset"), []byte("DGC"), []byte("1"), []byte("2"), []byte("3")}, shim.ERROR, "There is no DGC asset allowed")

    checkInvoke(t, stub, [][]byte{[]byte("transferAsset"), []byte("BTC"), []byte("1"), []byte("2"), []byte("3")}, shim.OK)    
    checkState(t, stub, BD_ACCOUNT_1, "{\"account\":\"1\",\"currency\":{\"BTC\":7}}")
    checkState(t, stub, BD_ACCOUNT_2, "{\"account\":\"2\",\"currency\":{\"BTC\":3}}")
}
