/*
 * The sample smart contract for documentation topic:
 * charging option
 */

package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}

// Define the states of the co_state
const ISSUE = 1
const BUY = 2
const DELIVERED = 3
const TIMELEN = 96
const L_CS = 9

// Define the ChargingOption structure, with 6 properties.  Structure tags are used by encoding/json library
// There is another ID of the ChargingOption, as the key
type ChargingOption struct {
	id_car   string `json:"id_car"`
	id_cs  string `json:"id_cs"`
	t_arrive string `json:"t_arrive"`
	t_leave  string `json:"t_leave"`
	co_price string `json:"co_price"`
	co_state string `json:"co_state"`
}

//type ChargingStationStatus struct {
//	bookedNumber string `json:""`
//}

/*
 * The Init method is called when the Smart Contract "fabcar" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "fabcar"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "queryCO" {
		return s.queryCO(APIstub, args)
	} else if function == "queryPrice" {
		return s.queryPrice(APIstub)
	} else if function == "initLedger" {
		return s.initLedger(APIstub)
	} else if function == "buy" {
		return s.buy(APIstub, args)
	} else if function == "post" {
		return s.post(APIstub, args)
	} else if function == "deliver" {
		return s.deliver(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

func (s *SmartContract) queryCO(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	coAsBytes, _ := APIstub.GetState(args[0])

	return shim.Success(coAsBytes)//coAsBytes does not include the co_id
}

func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	var chargingoption []ChargingOption
		for i := 0;i< L_CS;i++ {
			for j := 0;j < TIMELEN;j++ {
				temp := ChargingOption{
						id_car:   "CS",
						id_cs:    strconv.Itoa(i),//
						t_arrive: strconv.Itoa(j),//time
						t_leave:  strconv.Itoa(j),//time
						co_price: strconv.Itoa(0),//book number
						co_state: strconv.Itoa(ISSUE),
					}
				chargingoption = append(chargingoption, temp)
			}
	}

	i := 0
	for i < len(chargingoption) {
		fmt.Println("i is ", i)
		coAsBytes, _ := json.Marshal(chargingoption[i])
		APIstub.PutState("ChargingStationStatus"+strconv.Itoa(i), coAsBytes)
		fmt.Println("Added", chargingoption[i])
		i = i + 1
	}

	return shim.Success(nil)
}

func (s *SmartContract) buy(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}

	var chargingoption = ChargingOption{id_car: args[1], id_cs: args[2], t_arrive: args[3], t_leave: args[4],
		co_state:strconv.Itoa(BUY)}

	// the problem about lock???
	coAsBytes, _ := json.Marshal(chargingoption)
	APIstub.PutState(args[0], coAsBytes)

	return shim.Success(nil)
}

func (s *SmartContract) queryPrice(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "ChargingStationStatus0"
	endKey := "ChargingStationStatus999"

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryPrice:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (s *SmartContract) post(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	coAsBytes, _ := APIstub.GetState(args[0])
	chargingoption := ChargingOption{}

	json.Unmarshal(coAsBytes, &chargingoption)
	if chargingoption.co_state == strconv.Itoa(DELIVERED) {
		return shim.Error("The charging option is ")
	}
	chargingoption.co_state = strconv.Itoa(ISSUE)
	chargingoption.co_price = args[1]

	coAsBytes, _ = json.Marshal(chargingoption)
	APIstub.PutState(args[0], coAsBytes)

	return shim.Success(nil)
}

func (s *SmartContract) deliver(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	coAsBytes, _ := APIstub.GetState(args[0])
	chargingoption := ChargingOption{}

	json.Unmarshal(coAsBytes, &chargingoption)
	chargingoption.co_state = strconv.Itoa(DELIVERED)

	coAsBytes, _ = json.Marshal(chargingoption)
	APIstub.PutState(args[0], coAsBytes)

	return shim.Success(nil)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
