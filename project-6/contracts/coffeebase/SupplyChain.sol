pragma solidity ^0.4.24;

import "../coffeecore/Ownable.sol"; //MZ ADDED
import "../coffeeaccesscontrol/ConsumerRole.sol"; //MZ ADDED
import "../coffeeaccesscontrol/DistributorRole.sol"; //MZ ADDED
import "../coffeeaccesscontrol/FarmerRole.sol"; //MZ ADDED
import "../coffeeaccesscontrol/RetailerRole.sol"; //MZ ADDED

// Define a contract 'Supplychain'
contract SupplyChain is Ownable, ConsumerRole, DistributorRole, FarmerRole, RetailerRole { //MZ UPDATED WITH "..IS OWN....."

  // Define 'owner'
  address contractowner; //MZ CHANGED FOR CONFLICTING DECLARATION ERROR UPON COMPILATION.  GUIDANCE PER UDACITY KNOWLEDGE CASE OPENED BY 'Djordje' WITH TITLE "can't compile code" SAID TO COMMENT OUT, BUT CAUSED FUTURE ERRORS SO JUST CHANGED NAME SO NO MORE CONFLICT

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Harvested,  // 0
    Processed,  // 1
    Packed,     // 2
    ForSale,    // 3
    Sold,       // 4
    Shipped,    // 5
    Received,   // 6
    Purchased   // 7
    }

  State constant defaultState = State.Harvested;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address originFarmerID; // Metamask-Ethereum address of the Farmer
    string  originFarmName; // Farmer Name
    string  originFarmInformation;  // Farmer Information
    string  originFarmLatitude; // Farm Latitude
    string  originFarmLongitude;  // Farm Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address distributorID;  // Metamask-Ethereum address of the Distributor
    address retailerID; // Metamask-Ethereum address of the Retailer
    address consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event Harvested(uint upc);
  event Processed(uint upc);
  event Packed(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);
  event Shipped(uint upc);
  event Received(uint upc);
  event Purchased(uint upc);

  // Define a modifer that checks to see if msg.sender == owner of the contract
  // modifier onlyOwner() {
  //  require(msg.sender == owner);
  //  _;
  // } //MZ COMMENTED OUT BECAUSE OF COMPILATION ERROR AND REVIEW SHOWS THAT THIS IS ALREADY IMPORTED FROM THE OWNABLE.SOL FILE

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].consumerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Harvested
  modifier harvested(uint _upc) {
    require(items[_upc].itemState == State.Harvested);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Processed
  modifier processed(uint _upc) {
    require(items[_upc].itemState == State.Processed); //MZ ADDED
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Packed
  modifier packed(uint _upc) {
    require(items[_upc].itemState == State.Packed); //MZ ADDED
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale); //MZ ADDED
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier sold(uint _upc) {
    require(items[_upc].itemState == State.Sold); //MZ ADDED
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].itemState == State.Shipped); //MZ ADDED
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
    require(items[_upc].itemState == State.Received); //MZ ADDED
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Purchased
  modifier purchased(uint _upc) {
    require(items[_upc].itemState == State.Purchased); //MZ ADDED
    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    contractowner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == contractowner) {
      selfdestruct(contractowner);
    }
  }

  // Define a function 'harvestItem' that allows a farmer to mark an item 'Harvested'
  function harvestItem(uint _upc, address _originFarmerID, string _originFarmName, string _originFarmInformation, string  _originFarmLatitude, string  _originFarmLongitude, string  _productNotes) public 
    onlyFarmer()
  {
    // Add the new item as part of Harvest
    items[_upc].sku = sku; //MZ ADDED
    items[_upc].upc = _upc; //MZ ADDED

    //MZ ADDED - create productID as recommended in the Item struct above
    uint _productID = sku + _upc; //MZ ADDED

    items[_upc].ownerID = _originFarmerID; //MZ ADDED
    items[_upc].originFarmerID = _originFarmerID; //MZ ADDED
    items[_upc].originFarmName = _originFarmName; //MZ ADDED
    items[_upc].originFarmInformation = _originFarmInformation; //MZ ADDED
    items[_upc].originFarmLatitude = _originFarmLatitude; //MZ ADDED
    items[_upc].originFarmLongitude = _originFarmLongitude; //MZ ADDED
    items[_upc].productID = _productID; //MZ ADDED
    items[_upc].productNotes = _productNotes; //MZ ADDED
    items[_upc].itemState = State.Harvested; //MZ ADDED
    
    // Increment sku
    sku = sku + 1;

    // Emit the appropriate event
    emit Harvested(_upc); //MZ ADDED
  }

  // Define a function 'processtItem' that allows a farmer to mark an item 'Processed'
  function processItem(uint _upc) public
  // Call modifier to check if upc has passed previous supply chain stage
    harvested(_upc) //MZ ADDED
    onlyFarmer() //MZ ADDED
  // Call modifier to verify caller of this function
    verifyCaller(items[_upc].originFarmerID) //MZ ADDED
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Processed; //MZ ADDED

    // Emit the appropriate event
    emit Processed(_upc); //MZ ADDED
  }

  // Define a function 'packItem' that allows a farmer to mark an item 'Packed'
  function packItem(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
    processed(_upc) //MZ ADDED
    onlyFarmer() //MZ ADDED
  // Call modifier to verify caller of this function
    verifyCaller(items[_upc].originFarmerID) //MZ ADDED
  {
    // Update the appropriate fields
    items[_upc].itemState = State.Packed; //MZ ADDED

    // Emit the appropriate event
    emit Packed(_upc); //MZ ADDED
  }

  // Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
  function sellItem(uint _upc, uint _price) public 
  // Call modifier to check if upc has passed previous supply chain stage
    packed(_upc) //MZ ADDED
    onlyFarmer() //MZ ADDED
  // Call modifier to verify caller of this function
    verifyCaller(items[_upc].originFarmerID) //MZ ADDED
  {
    // Update the appropriate fields
    items[_upc].itemState = State.ForSale; //MZ ADDED
    items[_upc].productPrice = _price; //MZ ADDED

    // Emit the appropriate event
    emit ForSale(_upc); //MZ ADDED
  }

  // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function buyItem(uint _upc, address _distributorID) public payable 
    // Call modifier to check if upc has passed previous supply chain stage
    forSale(_upc) //MZ ADDED
    onlyDistributor() //MZ ADDED
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice) //MZ ADDED
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc) //MZ ADDED
    {
    
    // Update the appropriate fields - ownerID, distributorID, itemState
    items[_upc].ownerID = msg.sender; //MZ ADDED
    items[_upc].distributorID = _distributorID; //MZ ADDED
    items[_upc].itemState = State.Sold; //MZ ADDED
    // Transfer money to farmer
    uint productPrice = items[_upc].productPrice; //MZ ADDED
    items[_upc].originFarmerID.transfer(productPrice); //MZ ADDED

    // emit the appropriate event
    emit Sold(_upc); //MZ ADDED
  }

  // Define a function 'shipItem' that allows the distributor to mark an item 'Shipped'
  // Use the above modifers to check if the item is sold
  function shipItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    sold(_upc) //MZ ADDED
    onlyDistributor() //MZ ADDED
    // Call modifier to verify caller of this function
    verifyCaller(items[_upc].distributorID) //MZ ADDED
    {
    // Update the appropriate fields
    items[_upc].itemState = State.Shipped; //MZ ADDED

    // Emit the appropriate event
    emit Shipped(_upc); //MZ ADDED
  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc, address _retailerID) public 
    // Call modifier to check if upc has passed previous supply chain stage
    shipped(_upc) //MZ ADDED
    // Access Control List enforced by calling Smart Contract / DApp
    onlyRetailer() //MZ ADDED
    {
    // Update the appropriate fields - ownerID, retailerID, itemState
    items[_upc].ownerID = msg.sender; //MZ ADDED
    items[_upc].retailerID = _retailerID; //MZ ADDED
    items[_upc].itemState = State.Received; //MZ ADDED
    
    // Emit the appropriate event
    emit Received(_upc); //MZ ADDED
      }

  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
  // Use the above modifiers to check if the item is received
  function purchaseItem(uint _upc, address _consumerID) public 
    // Call modifier to check if upc has passed previous supply chain stage
    received(_upc) //MZ ADDED
    // Access Control List enforced by calling Smart Contract / DApp
    onlyConsumer() //MZ ADDED
    {
    // Update the appropriate fields - ownerID, consumerID, itemState
    items[_upc].ownerID = msg.sender; //MZ ADDED
    items[_upc].consumerID = _consumerID; //MZ ADDED
    items[_upc].itemState = State.Purchased; //MZ ADDED  
    
    // Emit the appropriate event
    emit Purchased(_upc); //MZ ADDED
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originFarmerID,
  string  originFarmName,
  string  originFarmInformation,
  string  originFarmLatitude,
  string  originFarmLongitude
  ) 
  {
  // Assign values to the 8 parameters
  itemSKU = items[_upc].sku; //MZ ADDED
  itemUPC = items[_upc].upc; //MZ ADDED
  ownerID = items[_upc].ownerID; //MZ ADDED
  originFarmerID = items[_upc].originFarmerID; //MZ ADDED
  originFarmName = items[_upc].originFarmName; //MZ ADDED
  originFarmInformation = items[_upc].originFarmInformation; //MZ ADDED
  originFarmLatitude = items[_upc].originFarmLatitude; //MZ ADDED
  originFarmLongitude = items[_upc].originFarmLongitude; //MZ ADDED
  
  
  return 
  (
  itemSKU,
  itemUPC,
  ownerID,
  originFarmerID,
  originFarmName,
  originFarmInformation,
  originFarmLatitude,
  originFarmLongitude
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  uint    productID,
  string  productNotes,
  uint    productPrice,
  uint    itemState,
  address distributorID,
  address retailerID,
  address consumerID
  ) 
  {
    // Assign values to the 9 parameters
  itemSKU = items[_upc].sku; //MZ ADDED
  itemUPC = items[_upc].upc; //MZ ADDED
  productID = items[_upc].productID; //MZ ADDED
  productNotes = items[_upc].productNotes; //MZ ADDED
  productPrice = items[_upc].productPrice; //MZ ADDED
  itemState = uint(items[_upc].itemState); //MZ ADDED
  distributorID = items[_upc].distributorID; //MZ ADDED
  retailerID = items[_upc].retailerID; //MZ ADDED
  consumerID = items[_upc].consumerID; //MZ ADDED
      
  return 
  (
  itemSKU,
  itemUPC,
  productID,
  productNotes,
  productPrice,
  itemState,
  distributorID,
  retailerID,
  consumerID
  );
  }
}