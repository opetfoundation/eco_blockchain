package main

import (
    "fmt"
    "errors"
    "encoding/json"

    "github.com/hyperledger/fabric/core/chaincode/shim"
    sc "github.com/hyperledger/fabric/protos/peer"
)

// OpetCode implements a simple chaincode
type OpetCode struct {

}

/*
    Uid - saves user's uid without account prefix
    Data - saves map of user propeties
*/
type User struct {
    Uid string `json:"UID"`
    Data map[string]string `json:"data"`
}

const USER_KEY = "_USER_"

// Init is called during chaincode instantiation to initialize any
// data. Note that chaincode upgrade also calls this function to reset
// or to migrate data.
func (t *OpetCode) Init(stub shim.ChaincodeStubInterface) sc.Response {
    return shim.Success(nil)
}

// Invoke is called per transaction on the chaincode. Each transaction is
// either a 'get' or a 'set' on the asset created by Init function. The Set
// method may create a new asset by specifying a new key-value pair.
func (t *OpetCode) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {
    fmt.Printf("Invoke function\n")
    // Retrieve the requested Smart Contract function and arguments
    function, args := APIstub.GetFunctionAndParameters()
    // Route to the appropriate handler function to interact with the ledger appropriately
    if function == "initLedger" {
        return t.initLedger(APIstub)
    } else if function == "createUser" {
        return t.createUser(APIstub, args)
    } else if function == "retrieveUser" {
        return t.retrieveUser(APIstub, args)
    }
    return shim.Error("Invalid Smart Contract function name.")
}

func (t *OpetCode) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
    return shim.Success(nil)
}

func (t *OpetCode) loadUser(APIstub shim.ChaincodeStubInterface, userKey string) (User, error) {
    user_json, _ := APIstub.GetState(userKey)
    var user User

    if user_json == nil {
        return user, errors.New("There is no user exist")
    }    
    _ = json.Unmarshal([]byte(user_json), &user)    
    return user, nil
} 

/*
    Creates user with propeties
    arg0 - user uid
    arg1 - user propeties: string -> string
*/
func (t *OpetCode) createUser(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 2 {
        return shim.Error("Incorrect number of arguments. Expecting 2")
    }

    uid := args[0]
    json_props := args[1]
    user_key, _ := APIstub.CreateCompositeKey(uid, []string{USER_KEY})

    if _, err := t.loadUser(APIstub, user_key); err == nil {
        return shim.Error("Account already exists")
    }
    new_user := new(User)
    new_user.Uid = uid
    new_user.Data = make(map[string]string)
    err := json.Unmarshal([]byte(json_props), &new_user.Data)
    if err != nil {
        return shim.Error("Can't parse json props")
    }

    new_user_json, _ := json.Marshal(new_user)
    APIstub.PutState(user_key, new_user_json)

    return shim.Success(nil)
}

/*
    Returns all account assets balances
    arg0 - account
*/
func (t *OpetCode) retrieveUser(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

    if len(args) != 1 {
        return shim.Error("Incorrect number of arguments. Expecting 1")
    }
    uid := args[0]
    user_key, _ := APIstub.CreateCompositeKey(uid, []string{USER_KEY})
    user, err := t.loadUser(APIstub, user_key)
    if err != nil {
        return shim.Error(fmt.Sprintf("The %s user doesn't not exist", uid))
    }
    user_json, _ := json.Marshal(user)
    fmt.Printf("%s \n", user_json)
    return shim.Success(user_json)
}



// main function starts up the chaincode in the container during instantiate
func main() {
    fmt.Printf("starting OpetCode chaincode")
    if err := shim.Start(new(OpetCode)); err != nil {
            fmt.Printf("Error starting OpetCode chaincode: %s", err)
    }
}
