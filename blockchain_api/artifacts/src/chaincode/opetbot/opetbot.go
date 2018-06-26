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
    Documents []string `json:"documents"`
    Files []string `json:"files"`
}

/*
    Document represents an arbitrary json document with user's data
    Data - keeps json
*/
type Document struct {
    Data map[string]interface{} `json:"data"`
}

type FileStatus int

const (
   Valid    FileStatus = 0
   Unvalid    FileStatus = 1
   Verifying FileStatus = 2
)

type File struct { 
    Hash string `json:"hash"`
    Status FileStatus `json:"status"`
}

const USER_KEY = "_USER_"
const DOCUMENT_KEY = "__DOCUMENT__"
const FILE_KEY = "_FILE_"


/*
    The function runs at chaincode initiation or update
*/
func (t *OpetCode) Init(stub shim.ChaincodeStubInterface) sc.Response {
    return shim.Success(nil)
}

// Invoke is called per transaction on the chaincode.
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
    } else if function == "createDocument" {
        return t.createDocument(APIstub, args)
    } else if function == "retrieveDocument" {
        return t.retrieveDocument(APIstub, args)
    }
    return shim.Error("Invalid Smart Contract function name.")
}


func (t *OpetCode) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
    return shim.Success(nil)
}

/*
    loadUser is a helper to load the user structure from the storage by userKey.
    Also checks, if user exists.
*/
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
    loadDocument is a helper to load the document structure from the storage by docKey.
    Also checks, if document exists.
*/
func (t *OpetCode) loadDocument(APIstub shim.ChaincodeStubInterface, docKey string) (Document, error) {
    doc_json, _ := APIstub.GetState(docKey)
    var document Document

    if doc_json == nil {
        return document, errors.New("There is no document exist")
    }    
    _ = json.Unmarshal([]byte(doc_json), &document)    
    return document, nil
} 

/*
    loadFile is a helper to load the file structure from the storage by fileKey.
    Also checks, if file exists.
*/
func (t *OpetCode) loadFile(APIstub shim.ChaincodeStubInterface, fileKey string) (File, error) {
    file_json, _ := APIstub.GetState(fileKey)
    var file File

    if file_json == nil {
        return file, errors.New("There is no file exist")
    }    
    _ = json.Unmarshal([]byte(file_json), &file)    
    return file, nil
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

/*
    createDocument creates a new document for the user
    arg0 - user uid
    arg1 - document uid
    arg2 - document json
*/
func (t *OpetCode) createDocument(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 3 {
        return shim.Error("Incorrect number of arguments. Expecting 3")
    }

    user_uid := args[0]
    uid := args[1]
    json_props := args[2]
    doc_key, _ := APIstub.CreateCompositeKey(uid, []string{DOCUMENT_KEY})
    user_key, _ := APIstub.CreateCompositeKey(user_uid, []string{USER_KEY})

    if _, err := t.loadDocument(APIstub, doc_key); err == nil {
        return shim.Error("Document already exists")
    }

    user, err := t.loadUser(APIstub, user_key)
    if err != nil {
        return shim.Error(fmt.Sprintf("The %s user doesn't not exist", user_uid))
    }
    user.Documents = append(user.Documents, uid)


    new_doc := new(Document)
    new_doc.Data = make(map[string]interface{})
    err = json.Unmarshal([]byte(json_props), &new_doc.Data)
    if err != nil {
        return shim.Error("Can't parse json props")
    }

    new_doc_json, _ := json.Marshal(new_doc)
    APIstub.PutState(doc_key, new_doc_json)

    user_json, _ := json.Marshal(user)
    APIstub.PutState(user_key, user_json)

    return shim.Success(nil)
}


/*
    retrieveDocument returns the document by it's uid and user's uid.
    Checks that the user owns the requested document.
    arg0 - user uid
    arg1 - document uid
*/
func (t *OpetCode) retrieveDocument(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

    if len(args) != 2 {
        return shim.Error("Incorrect number of arguments. Expecting 2")
    }
    user_uid := args[0]
    doc_uid := args[1]

    user_key, _ := APIstub.CreateCompositeKey(user_uid, []string{USER_KEY})
    user, err := t.loadUser(APIstub, user_key)
    if err != nil {
        return shim.Error(fmt.Sprintf("The %s user doesn't not exist", user_uid))
    }
    found := false
    for i := range user.Documents {
    if user.Documents[i] == doc_uid {
        found = true
        break
        }
    }
    if !found {
        return shim.Error(fmt.Sprintf("The user: %s doesn't have document: %s", user_uid, doc_uid))
    }



    doc_key, _ := APIstub.CreateCompositeKey(doc_uid, []string{DOCUMENT_KEY})
    doc, err := t.loadDocument(APIstub, doc_key)
    if err != nil {
        return shim.Error(fmt.Sprintf("The %s document does not exist", doc_uid))
    }



    doc_json, _ := json.Marshal(doc)
    fmt.Printf("%s \n", doc_json)
    return shim.Success(doc_json)
}

func (t *OpetCode) createFile(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
    if len(args) != 3 {
        return shim.Error("Incorrect number of arguments. Expecting 3")
    }
    user_uid := args[0]
    file_uid := args[1]
    file_hash := args[2]

    file_key, _ := APIstub.CreateCompositeKey(file_uid, []string{FILE_KEY})
    user_key, _ := APIstub.CreateCompositeKey(user_uid, []string{USER_KEY})

    if _, err := t.loadFile(APIstub, file_key); err == nil {
        return shim.Error("File already exists")
    }

    user, err := t.loadUser(APIstub, user_key)
    if err != nil {
        return shim.Error(fmt.Sprintf("The %s user doesn't not exist", user_uid))
    }
    new_file := File{Hash: file_hash, Status: Valid}
    user.Files = append(user.Files, file_uid)

    new_file_json, _ := json.Marshal(new_file)
    APIstub.PutState(file_key, new_file_json)

    user_json, _ := json.Marshal(user)
    APIstub.PutState(user_key, user_json)

    return shim.Success(nil)

}



// main function starts up the chaincode in the container during instantiate
func main() {
    fmt.Printf("starting OpetCode chaincode")
    if err := shim.Start(new(OpetCode)); err != nil {
            fmt.Printf("Error starting OpetCode chaincode: %s", err)
    }
}
