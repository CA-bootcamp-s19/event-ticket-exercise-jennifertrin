pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.
        Use the appropriate keyword to allow ether transfers.
     */
    address payable public owner;
    uint   TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */

    Event my event;
    struct Event {
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    }

    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    event LogBuyTickets(address buyer, uint quantity);
    event LogGetRefund(address payable requester, uint quantity);
    event LogEndSale(address payable owner, uint earnings);
    

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier ifOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */
    constructor(string description, string website, uint _totalTickets) public
    {
        owner = msg.sender;
        myEvent.description = _description;
        myEvent.website = _website;
        myEvent.totalTickets = _totalTickets;
        myEvent.isOpen = true;
    }
    

    /*
        Define a function called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint numberTickets, uint sales, bool isOpen in that order.
    */
    function readEvent()
        public
        returns(string memory description, string memory website, uint numberTickets, uint sales, bool isOpen)
    {

    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    function getBuyerNumberTickets(uint eventId) public view returns (uint){
        return events[eventId].buyers[msg.sender];
    }

    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */
    function buyTickets(uint _id, uint numberTickets) public
        payable
    {
        Event storage selected = events[_id];
        uint numberTickets = price_ticket * _quantity;
        require(selected.isOpen, "Closed event not available");
        require(numberTickets <= msg.value, "Not enough money to buy");
        require(numberTickets <= selected.numberTickets - selected.sales, "Not enough available tickets");

        selected.buyers[msg.sender] += _quantity;
        selected.sales += _quantity;
        uint refund = msg.value - total;
        msg.sender.transfer(refund);
        emit BuyTickets(msg.sender, _id, _quantity);
    }

    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */
     function getRefund(uint eventId)public {
            Event storage anEvent = events[eventId];

            uint ticketsPurchased = anEvent.buyers[msg.sender];
            require(ticketsPurchased > 0, "Buyer didn't buy tickets.");

            anEvent.sales -= ticketsPurchased;
            anEvent.buyers[msg.sender] = 0;
            uint totalCost = ticketsPurchased * PRICE_TICKET;
            msg.sender.transfer(totalCost);
            emit LogGetRefund(
                msg.sender,
                totalCost,
                ticketsPurchased
            );
    }

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */
    function endSale(uint eventId) public
        ifOwner {
        events[eventId].isOpen = false;
}
