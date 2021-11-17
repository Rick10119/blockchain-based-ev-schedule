/*
 * The smart contract for charging option platform
 *
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

// Define the states of the CO_state
const ISSUE = 1     //co issued (by buying or delisting), waiting to be paid
const BUY = 2       //co paid by the user and therefore able to list
const LIST = 3      //co listed by the owner, thus able to be seen and delist 

// The parameters of the platform
const NofTime = 12  //number of time slots
const NofCS = 10.0      //number of charging stations
const J = 1.0/16.0      // unit revenue of charging, used for calculating co price
const w = 24.0/60.0         // average unit cost of time, used for calculating co price
const mu = 4.0        // average charging rate, used for calculating co price
const NofSlots = 6.0 // Number of charging slots, each station
const t0 = 30.0 // average charging time
const c = NofSlots * NofCS * mu // charging capacity of the system

// Define the ChargingOption structure, with 6 properties.  Structure tags are used by encoding/json library
// ID_CO of the ChargingOption as the key, as the following are the value
type ChargingOption struct {
	ID_car   string `json:"ID_car"`
	ID_cs    string `json:"ID_cs"`
	CO_T string `json:"CO_T"`
	T_arrive string `json:"T_arrive"`
	T_charge string `json:"T_charge"`
	CO_price string `json:"CO_price"`
	CO_state string `json:"CO_state"`
}

// ID_cs of the Charging Station as the key, as the following are the value
type StationState struct {
	ID_cs    string `json:"ID_cs"`
	AvailableTime string `json:"AvailableTime"`
}

// CO_T of the Time Slot as the key, as the following are the value
type TimeSlotState struct {
	CO_T string `json:"CO_T"`
	Lambda_b string `json:"Lambda_b"`
	CO_price string `json:"CO_price"`
	ExpectWaitTime string `json:"ExpectWaitTime"`
}

/*
 * The Init method is called when the Smart Contract "chargingoption" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "chargingoption"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "queryCO" {
		return s.queryCO(APIstub, args)
	} else if function == "queryTime" {
		return s.queryTime(APIstub, args)
	} else if function == "queryCS" {
		return s.queryCS(APIstub, args)
	} else if function == "queryList" {
		return s.queryList(APIstub, args)
	}else if function == "initLedger" {
		return s.initLedger(APIstub)
	} else if function == "buyCO" {
		return s.buyCO(APIstub, args)
	} else if function == "list" {
		return s.list(APIstub, args)
	} else if function == "delist" {
		return s.delist(APIstub, args)
	} else if function == "confirm" {
		return s.confirm(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

/**
  根据CO键查询充电权内容
*/
func (s *SmartContract) queryCO(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// args[0]: ID_CO
	// return charging option string of the corresponding ID_CO
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	// get the charging option from the world state
	coAsBytes, _ := APIstub.GetState(args[0])

	return shim.Success(coAsBytes) //coAsBytes does not include the co_id
}

/**
  根据CO_T键查询时段预计排队时间、充电权价格(只需要输入充电时间)
*/
func (s *SmartContract) queryTime(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// args[0]: T_charge
	// return CO_T, price, ExpectWaitTime  string
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	T_charge, err := strconv.Atoi(args[0])
	if err != nil {
		return shim.Error("Invalid time amount, expecting a double value")
	}

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	var price int
	var expectTime int
	// for each station, calculate the price
	for j := 0; j < NofTime; j++ {

		// to get the state of the charging station
		tssAsBytes, _ := APIstub.GetState("TimeSlot" + strconv.Itoa(j))

		timeSlotState := TimeSlotState{}

		_ = json.Unmarshal(tssAsBytes, &timeSlotState)

		priceT, _ := strconv.Atoi(timeSlotState.CO_price)

		expectTime, _ = strconv.Atoi(timeSlotState.ExpectWaitTime)

		price = priceT * T_charge / t0

		buffer.WriteString("时段: ")
		buffer.WriteString(strconv.Itoa(j))

		buffer.WriteString(", 充电权价格（元）: ")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(strconv.Itoa(price))

		buffer.WriteString(", 预计排队时间(分钟): ")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(strconv.Itoa(expectTime))
		buffer.WriteString("\n")

	}
	fmt.Printf("- queryTime:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

/**
  查询充电站排队时间（输入预计到达时间）
*/
func (s *SmartContract) queryCS(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// args[0]: T_arrive
	// return station, waitTime  string
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	T_arrive, err := strconv.Atoi(args[0])
	if err != nil {
		return shim.Error("Invalid time amount, expecting a integer value")
	}

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer

	// for each station, calculate the price
	for j := 0; j < NofCS; j++ {

		// to get the state of the charging station
		ssAsBytes, _ := APIstub.GetState("Station" + strconv.Itoa(j))

		stationState := StationState{}

		_ = json.Unmarshal(ssAsBytes, &stationState)

		availableTime, _ := strconv.Atoi(stationState.AvailableTime)

		// 预计等待时间
		waitTime := availableTime - T_arrive
		if waitTime < 0 {
			waitTime = 0
		}

		buffer.WriteString("充电站: ")
		buffer.WriteString(strconv.Itoa(j))

		buffer.WriteString(", 等待时间（分钟）: ")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(strconv.Itoa(waitTime))
		buffer.WriteString("\n")

	}
	fmt.Printf("- queryPrice:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (s *SmartContract) queryList(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {


	queryString := fmt.Sprintf("{\"selector\":{\"CO_state\":\"3\"}}")


	queryResults, err := getQueryResultForQueryString(APIstub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(queryResults) //coAsBytes does not include the co_id
}

/**
  账本初始化，都设成0.测试的时候可以不一样
*/
func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	// The initial state of the stations
	var price_1b float32
	var price_2b float32
	var Lambda_b float32
	var stationstate StationState
	var timeslotstate TimeSlotState
	// J is written as 1/4 to guarantee the determinacy of the result

	// init the station states
	for i := 0; i < NofCS; i++ {
		stationstate = StationState{
			ID_cs:    strconv.Itoa(i),
			AvailableTime: strconv.Itoa(i * 5),
		}
		ssAsBytes, _ := json.Marshal(stationstate)
		APIstub.PutState("Station"+strconv.Itoa(i), ssAsBytes)
		fmt.Println("Added:", stationstate)
	}

	// init the time slot states
	for i := 0; i < NofTime; i++ {
		Lambda := [] float32 {22,   23,   40,  231,  136,  215,  125,  146,  235,  230,  154,   31}
		Lambda_b = Lambda[i]
		price_1b = t0 * w * Lambda_b * c * J /(c - Lambda_b)/(c - Lambda_b)
		price_2b = 0
		ExpectWaitTime := t0 * (J * Lambda_b/(c - Lambda_b))
		timeslotstate = TimeSlotState{
			CO_T:    strconv.Itoa(i),
			Lambda_b: strconv.Itoa(int(Lambda_b)),
			CO_price: strconv.Itoa(int(price_1b + price_2b)),
			ExpectWaitTime: strconv.Itoa(int(ExpectWaitTime)),
		}
		tssAsBytes, _ := json.Marshal(timeslotstate)
		APIstub.PutState("TimeSlot"+strconv.Itoa(i), tssAsBytes)
		fmt.Println("Added:", timeslotstate)
	}

	return shim.Success(nil)
}

/**
  购买充电权（时段）
*/
func (s *SmartContract) buyCO(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	// create a new charging option
	var chargingoption = ChargingOption{ID_car: args[1], CO_T: args[2], T_charge: args[3]}

	chargingoption.CO_state = strconv.Itoa(ISSUE)
	// to calculate the price
	var price int
	price = 0
	CO_T, err := strconv.Atoi(args[2])
	if err != nil {
		return shim.Error("Invalid time amount, expecting a integer value")
	}
	T_charge, err := strconv.Atoi(args[3])
	if err != nil {
		return shim.Error("Invalid time amount, expecting a integer value")
	}

	var price_1b float32
	var price_2b float32
	var Lambda_b int
	// to get the state of the charging station and deserialize into stationstateT
	timeSlotID := "TimeSlot" + strconv.Itoa(CO_T)
	tssAsBytes, _ := APIstub.GetState(timeSlotID)
	timeSlotState := TimeSlotState{}
	_ = json.Unmarshal(tssAsBytes, &timeSlotState)

	// read the price and state now
	priceT, _ := strconv.Atoi(timeSlotState.CO_price)
	Lambda_b, _ = strconv.Atoi(timeSlotState.Lambda_b)
	// add the price of the current time slot T
	price = priceT * T_charge / t0

	// change the state(Lambda_b) of the particular charging station by +1
	Lambda := float32(Lambda_b) + 1
	price_1b = t0 * w * Lambda * c * J /(c - Lambda)/(c - Lambda)
	price_2b = 0
	ExpectWaitTime := t0 * (J * Lambda/(c - Lambda))
	timeSlotState = TimeSlotState{
		CO_T:    strconv.Itoa(CO_T),
		Lambda_b: strconv.Itoa(Lambda_b + 1),
		CO_price: strconv.Itoa(int(price_1b + price_2b)),
		ExpectWaitTime: strconv.Itoa(int(ExpectWaitTime)),
	}

	// 更新时段状态
	tssAsBytes, _ = json.Marshal(timeSlotState)
	APIstub.PutState("TimeSlot"+strconv.Itoa(CO_T), tssAsBytes)
	fmt.Println("Added:", tssAsBytes)

	// 生成充电权
	chargingoption.CO_price = strconv.Itoa(price)
	// the problem about lock???
	coAsBytes, _ := json.Marshal(chargingoption)
	APIstub.PutState(args[0], coAsBytes)

	return shim.Success(nil)
}


/**
  挂牌
*/
func (s *SmartContract) list(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	// fetch the co according to the ID_CO
	coAsBytes, _ := APIstub.GetState(args[0])
	chargingoption := ChargingOption{}
	_ = json.Unmarshal(coAsBytes, &chargingoption)

	// the user can list his/her co only if the co has been paid (and then set delivered by cs)
	if chargingoption.CO_state != strconv.Itoa(BUY) {
		return shim.Error("The charging option is not paid yet!")
	}
	chargingoption.CO_state = strconv.Itoa(LIST)
	chargingoption.CO_price = args[1]

	coAsBytes, _ = json.Marshal(chargingoption)
	APIstub.PutState(args[0], coAsBytes)


	return shim.Success(nil)
}

/**
  摘牌
*/
func (s *SmartContract) delist(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	coAsBytes, _ := APIstub.GetState(args[0])
	chargingoption := ChargingOption{}

	_ = json.Unmarshal(coAsBytes, &chargingoption)
	if chargingoption.CO_state != strconv.Itoa(LIST) {
		return shim.Error("The charging option is NOT listed yet!")
	}
	chargingoption.CO_state = strconv.Itoa(ISSUE)
	chargingoption.ID_car = args[1]

	coAsBytes, _ = json.Marshal(chargingoption)
	APIstub.PutState(args[0], coAsBytes)

	return shim.Success(nil)
}

func (s *SmartContract) confirm(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	coAsBytes, _ := APIstub.GetState(args[0])
	chargingoption := ChargingOption{}

	_ = json.Unmarshal(coAsBytes, &chargingoption)
	if chargingoption.CO_state == strconv.Itoa(BUY) {
		return shim.Error("Confirmation is not needed!")
	}
	chargingoption.CO_state = strconv.Itoa(BUY)

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

// Two functions to support rich query of listed charging options
func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err
	}

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())

	return buffer.Bytes(), nil
}

func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) (*bytes.Buffer, error) {
	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		buffer.WriteString("\"Listed Charging Option\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("\n")

	}

	return &buffer, nil
}
