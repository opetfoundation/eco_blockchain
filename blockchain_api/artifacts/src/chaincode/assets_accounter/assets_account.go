package main

import (
    "fmt"
    "errors"
    "encoding/json"
    "math/big"

    "github.com/hyperledger/fabric/core/chaincode/shim"
    sc "github.com/hyperledger/fabric/protos/peer"
)

// SimpleAsset implements a simple chaincode to manage an asset
type SimpleAsset struct {

}

/*
    Account - saves account id-key without account prefix
    Currency - saves map of account currencies amouts: BTC -> 10, LTC -> 3
*/
type UserAccount struct {
    Account string `json:"account"`
    Balance map[string]*big.Int `json:"currency"`
}

const ACCOUNT_KEY = "_ACCOUNT_"

// Init is called during chaincode instantiation to initialize any
// data. Note that chaincode upgrade also calls this function to reset
// or to migrate data.
func (t *SimpleAsset) Init(stub shim.ChaincodeStubInterface) sc.Response {
    return shim.Success(nil)
}

// Invoke is called per transaction on the chaincode. Each transaction is
// either a 'get' or a 'set' on the asset created by Init function. The Set
// method may create a new asset by specifying a new key-value pair.
func (t *SimpleAsset) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
    fmt.Printf("Invoke function\n")
    // Retrieve the requested Smart Contract function and arguments
    function, args := APIstub.GetFunctionAndParameters()
    // Route to the appropriate handler function to interact with the ledger appropriately
    if function == "initLedger" {
        return t.initLedger(APIstub)
    } else if function == "createAccount" {
        return t.createAccount(APIstub, args)
    } else if function == "addAllowedCurrency" {
        return t.addAllowedCurrency(APIstub, args)
    } else if function == "removeAllowedCurrency" {
        return t.removeAllowedCurrency(APIstub, args)
    } else if function == "transferAsset" {
        return t.transferAsset(APIstub, args)
    } else if function == "getAccountBalances" {
        return t.getAccountBalances(APIstub, args)
    } else if function == "updateAccountAsset" {
        return t.updateAccountAsset(APIstub, args)
    }
    return shim.Error("Invalid Smart Contract function name.")
}

func (t *SimpleAsset) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
    allowedCurrencies := map[string]bool{"BTC": true, "LTC": true}
    json_currencies, _ := json.Marshal(allowedCurrencies)
    APIstub.PutState("allowedCurrencies", json_currencies)
    return shim.Success(nil)
}

func (t *SimpleAsset) loadAccount(APIstub shim.ChaincodeStubInterface, accountKey string) (UserAccount, error) {
    account_json, _ := APIstub.GetState(accountKey)
    var account UserAccount
    _ = json.Unmarshal([]byte(account_json), &account)
    if account.Balance == nil {
        return account, errors.New("There is no account exist")
    }
    return account, nil
} 

func (t *SimpleAsset) isAllowedCurrency(APIstub shim.ChaincodeStubInterface, currency string) bool {
    json_currencies, _ := APIstub.GetState("allowedCurrencies")
    var allowedCurrencies map[string]bool
    _ = json.Unmarshal(json_currencies, &allowedCurrencies)
    if _, ok := allowedCurrencies[currency]; ok {
        return true
    }
    return false
}

/*
    arg0 - asset name, adds this asset to allowed operations with
*/
func (t *SimpleAsset) addAllowedCurrency(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 1 {
        return shim.Error("Incorrect arguments. Expected 1")
    }
    json_currencies, _ := APIstub.GetState("allowedCurrencies")
    var allowedCurrencies map[string]bool
    _ = json.Unmarshal(json_currencies, &allowedCurrencies)
    if t.isAllowedCurrency(APIstub, args[0]) {
        return shim.Error(fmt.Sprintf("The %s has been already allowed.", args[0]))
    }  
    allowedCurrencies[args[0]] = true
    json_currencies, _ = json.Marshal(allowedCurrencies)
    APIstub.PutState("allowedCurrencies", json_currencies)
    return shim.Success([]byte(fmt.Sprintf("Successfuly added new asset type %s", args[0])))
}

/*
    arg0 - asset name, removes this asset from allowed operations
*/
func (t *SimpleAsset) removeAllowedCurrency(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 1 {
            return shim.Error("Incorrect arguments. Expected 1")
    }
    json_currencies, _ := APIstub.GetState("allowedCurrencies")
    var allowedCurrencies map[string]bool
    _ = json.Unmarshal([]byte(json_currencies), &allowedCurrencies)

    if _, ok := allowedCurrencies[args[0]]; ok {
        delete(allowedCurrencies, args[0])
        json_currencies, _ = json.Marshal(allowedCurrencies)
        APIstub.PutState("allowedCurrencies", json_currencies)
        return shim.Success([]byte(fmt.Sprintf("Successfuly removed %s", args[0])))
    }
    return shim.Error(fmt.Sprintf("There is no %s asset.", args[0]))
}

/*
    arg0 - asset name, that is going to be transfered
    arg1 - from_account, account that sends it's assets to to_account
    arg2 - to_account, accepts from_account asserts
    arg3 - amount of the assert
*/
func (t *SimpleAsset) transferAsset(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 4 {
            return shim.Error("Incorrect arguments. Expecting asset, from, to, amount")
    }

    tx_asset := args[0]
    if !t.isAllowedCurrency(APIstub, tx_asset) {
        return shim.Error(fmt.Sprintf("There is no %s asset allowed", args[0]))
    }

    from_account_key, _ := APIstub.CreateCompositeKey(args[1], []string{ACCOUNT_KEY})
    to_account_key, _ := APIstub.CreateCompositeKey(args[2], []string{ACCOUNT_KEY})
    if from_account_key == to_account_key {
        return shim.Error("Can not transfer the assert: target account is the same as source account.")
    }
    
    bigZero := new(big.Int)
    bigZero.SetString("0", 10)
    tx_amount, success := new(big.Int).SetString(args[3], 10)
    if !success {
        return shim.Error("Incorrect argument. Can't parse amount to int")
    }
    if tx_amount.Cmp(bigZero) < 0 {
        return shim.Error("Incorrect argument. Amount can't be belove zero")
    }

    from_account, err := t.loadAccount(APIstub, from_account_key)
    if err != nil {
        return shim.Error("There is no from_account exist")
    }
    to_account, err := t.loadAccount(APIstub, to_account_key)
    if err != nil {
        return shim.Error("There is no to_account exist")
    }

    from_balance, success := from_account.Balance[tx_asset]
    if !success {
        return shim.Error("Not enough balance at from account")
    }
    if from_balance.Cmp(tx_amount) < 0 {
        return shim.Error("Not enough balance at from account")
    }

    to_balance, success := to_account.Balance[tx_asset]
    if !success {
        to_balance = bigZero
    }

    from_balance.Sub(from_balance, tx_amount)
    to_balance.Add(to_balance, tx_amount)
    from_account.Balance[tx_asset] = from_balance
    to_account.Balance[tx_asset] = to_balance

    from_account_json, _ := json.Marshal(from_account)
    to_account_json, _ := json.Marshal(to_account)

    err_put := APIstub.PutState(from_account_key, from_account_json)
    if err_put != nil {
            return shim.Error(fmt.Sprintf("Failed save transaction: %s -> %s, %s %s", 
                from_account_key, to_account_key, tx_amount.String(), tx_asset))
    }

    err_put = APIstub.PutState(to_account_key, to_account_json)
    if err_put != nil {
            return shim.Error(fmt.Sprintf("Failed save transaction: %s -> %s, %s %s", 
                from_account_key, to_account_key, tx_amount.String(), tx_asset))
    }
    return shim.Success([]byte(fmt.Sprintf("Success transaction: %s -> %s, %s %s", 
        from_account_key, to_account_key, tx_amount.String(), tx_asset)))
}

/*
    Returns all account assets balances
    arg0 - account
*/
func (t *SimpleAsset) getAccountBalances(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

    if len(args) != 1 {
        return shim.Error("Incorrect number of arguments. Expecting 1")
    }
    account_key, _ := APIstub.CreateCompositeKey(args[0], []string{ACCOUNT_KEY})
    account, err := t.loadAccount(APIstub, account_key)
    if err != nil {
        return shim.Error(fmt.Sprintf("The %s account doesn't not exist", args[0]))
    }
    account_json, _ := json.Marshal(account)
    fmt.Printf("%s \n", account_json)
    return shim.Success(account_json)
}

/*
    Creates account
    arg0 - account id-key
*/
func (t *SimpleAsset) createAccount(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

    if len(args) != 1 {
        return shim.Error("Incorrect number of arguments. Expecting 1")
    }
    account_string := args[0]

    account_key, _ := APIstub.CreateCompositeKey(account_string, []string{ACCOUNT_KEY})
    if _, err := t.loadAccount(APIstub, account_key); err == nil {
        return shim.Error("Account already exists")
    }
    new_account := new(UserAccount)
    new_account.Account = account_string
    new_account.Balance = make(map[string]*big.Int)
    new_account_json, _ := json.Marshal(new_account)
    APIstub.PutState(account_key, new_account_json)

    return shim.Success(nil)
}

/*
    arg0 - asset name
    arg1 - account, that is going to be updated 
    arg2 - amount of the assert
*/
func (t *SimpleAsset) updateAccountAsset(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 3 {
        return shim.Error("Incorrect number of arguments. Expecting 3")
    }
    bigZero := new(big.Int)
    bigZero.SetString("0", 10)
    tx_asset := args[0]
    tx_account, _ := APIstub.CreateCompositeKey(args[1], []string{ACCOUNT_KEY})

    tx_amount_update := args[2]
    amount_update, success := new(big.Int).SetString(tx_amount_update, 10)
    if !success {
        return shim.Error("Can't parse currency amount")
    }
    if !t.isAllowedCurrency(APIstub, tx_asset) {
        return shim.Error(fmt.Sprintf("There is no %s asset allowed", tx_asset))
    }
    account, err := t.loadAccount(APIstub, tx_account)
    if err != nil {
        return shim.Error("Account does not exist")
    }

    current_balance, success := account.Balance[tx_asset]
    if success != true {
        current_balance = new(big.Int).Set(bigZero)
    }
    updated_balance := current_balance.Add(current_balance, amount_update)
    if updated_balance.Cmp(bigZero) < 0 {
        return shim.Error("Can't set currency amount belove zero")
    }

    account.Balance[tx_asset] = updated_balance
    account_json, _ := json.Marshal(account)
    err = APIstub.PutState(tx_account, account_json)
    if err != nil {
            return shim.Error(fmt.Sprintf("Failed save setAccountAssetAmount"))
    }
    fmt.Printf("%s \n", account_json)

    return shim.Success(nil)
}




// main function starts up the chaincode in the container during instantiate
func main() {
    fmt.Printf("starting SimpleAsset chaincode")
    if err := shim.Start(new(SimpleAsset)); err != nil {
            fmt.Printf("Error starting SimpleAsset chaincode: %s", err)
    }
}
