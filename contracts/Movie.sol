pragma solidity ^0.4.5;

contract Theatre {
    enum ShowType { morning, afternoon, evening, night } //4 shows each day
    enum SurpriseType { none, water, soda }
    event MovieEvent(address sender, string eventType, string movie);
    event TicketEvent(address sender, string eventType, uint8 ticket_no);
    event ShowEvent(address sender, string eventType, uint8 show_id);
    event SurpriseEvent(address sender, string eventType, string surprise);

    struct Ticket {
        //below information will be printed on ticket, and can be later varified against a request for same
        uint ticketId;                          //this can be later changed to hold any uuid or other unique number
        ShowType showType;                      //which show
        string customer_name;                   //customer name
        string customer_phone;                  //customer phone
        string movie_name;                      //movie name
        SurpriseType surprise;                  //early bird or other kind of offer
        //uint8 datetime;                       //movie day, here it is for current session
        uint8 personCount;                      //for how many persons
        uint8 totalAmount;                      //total amount
        bool surpriseCollected;                 //water and popcorn collected
        bool surpriseExchangeEligible;          //eligible for water soda exchange
        bool surpriseExchanged;                 //exchange attempted
        //uint8 [] seats;                       //seats occupied by booking, but we would assume here that it would be in sequence here
    }
    
    struct Screen {
        string movie;                           //movie name
        uint8 seats;                            //100 here
    }
    
    struct Show {
        ShowType showType;
        uint8 tickets;                          //for early bird and/or same offer
        
    } 

    string[] public movies;
    string public theatre_name;                 //theatre name
    string public theatre_location;             //theatre address
    uint8  movie_capacity;               //how many movies it can accomodate, here it would be 5 menas 5 movies
    mapping (uint8 => Ticket) tickets;     //tickets database
    mapping (uint8 => Show) shows;         //show database //both tickets and show can be combined to optimize storage
    uint8  ticketCntr;                   //to hold totalTickets, can be wiped off as soon as time expires
    uint8  showCntr;                     //to hold show counter
    uint8  ticketAmount;                 //ticket charges
    Show   currentShow;                  //ease of access to current show object 
    uint8  seat_capacity;                //seat capacity in each screen/room
    uint8  earlyBirdCounts;              //soda quantity in each show
    uint8  windows;                      //available windows
    mapping (string => Screen) screens;       //no of screens
    
    constructor(string theatrename, string loc) public {
        theatre_name = theatrename;
        movie_capacity = 5;                     //5 movies can run
        theatre_location = loc;                 //theatre location
        ticketAmount = 5;                       //$
        seat_capacity = 100;                    //seat capacity
        earlyBirdCounts = 200;                  //first 200 customers will get soda exchanged with water
        windows = 4;                            //we have 4 windows right now
    }
    
    modifier validTicket(uint8 tno) {
        require(ticketCntr >= tno, "This ticket is not valid.");
        _;
    }

    modifier seatsAvailable(string movie) {
        require(screens[movie].seats < 100, "We are full right now, please try in next show");
        _;
    }

    modifier validWindow(uint8 window) {
        require(window <= windows, "We are out of window.");
        _;
    }

    modifier canAddMovie() {
        require(movies.length < movie_capacity, "We cannot add more movie");
        _;
    }

    function addMovie(string movie) public canAddMovie returns(string movieid) {
        movieid = movie;
        movies.push(movie);
        emit MovieEvent(msg.sender,"added", movie);
        return movieid;
    }

    function createNewShow() public returns (uint8 show_id){
        show_id = showCntr;
        Show memory show = Show({
            showType: ShowType.morning,
            tickets: 0
        });
        shows[showCntr++] = show;
        currentShow = show;
        for(uint8 movieIndex; movieIndex < movies.length; movieIndex++) {
            string storage tempMovie = movies[movieIndex];
            screens[tempMovie] = Screen(tempMovie, 0);
        }
        emit ShowEvent(msg.sender, "created", show_id);
    }

    function bookTicket(string movie, uint8 window, ShowType show, string cname, string cphone, uint8 persons) public 
        seatsAvailable(movie)
        validWindow(window)
        returns (uint8 ticketid) {
        ticketid = ticketCntr;
        Ticket memory ticket = Ticket({
            ticketId: ticketCntr,
            showType: show,
            customer_name: cname,
            customer_phone: cphone,
            movie_name: movie,
            surprise: SurpriseType.none,
            //datetime: now,
            personCount: persons,
            totalAmount: persons * ticketAmount,
            surpriseCollected: false,
            surpriseExchangeEligible: false,
            surpriseExchanged: false
        });

        if(currentShow.tickets <= earlyBirdCounts) {
            //early bird offer eligible for first 200 customers
            ticket.surpriseExchangeEligible = true;
        }
        screens[movie].seats += persons;
        currentShow.tickets++;
        tickets[ticketCntr] = ticket;
        uint8 tempTicket = ticketCntr++;
        emit TicketEvent(msg.sender, "booked", tempTicket);
        return tempTicket;
    }
    
    function getTicket(uint8 tno) public 
        validTicket(tno) 
        view 
        returns (string customer, string phone, ShowType show, string movie, uint8 persons, uint8 amount) 
    {
        Ticket storage temp = tickets[tno];
        return (temp.customer_name, temp.customer_phone, temp.showType, temp.movie_name, temp.personCount, temp.totalAmount);
    }
    
    function claimSurprise(uint8 window, uint8 ticketNo) public returns (string message){
        //customer will come to window 1 and collect water bottle and popcorn
        //this method will be called by window manager, who would scan the ticket
        //and after scanning, he can enter ticket detail and verify ticket validity
        //here we are passing ticket no for simplicity.
        require(window == 1, "please collect these at window 1.");
        Ticket storage ticket = tickets[ticketNo];
        if(ticket.surpriseCollected) {
            message = "Our system is showing that we have already served you, sir.";
        } 
        else {
            //offer water bottle and pop corn to customer and mark the field
            ticket.surpriseCollected = true;
            //soda exchange logic
            //lets take the ticket no as a random number 
            ticket.surpriseExchangeEligible = (ticketNo % 2 == 0);
            message = "We are happy to serve you";
        }
        emit SurpriseEvent(msg.sender, "claimed", message);
    }

    function exchangeSurprise(uint8 ticketNo) public returns (string message) {
        //customer will come to cafeteria and get the water exchanged for soda
        //this method will be called by cafeteria manager, who would scan the ticket
        //and after scanning, he can enter ticket detail and verify ticket validity
        //here we are passing ticket no for simplicity.
        Ticket storage ticket = tickets[ticketNo];
        if(ticket.surpriseExchanged) {
            message = "Our system is showing that we have already served you, sir.";
        } else if (!ticket.surpriseExchangeEligible) {
            message = "You are not eligible for this offer";
        }
        else {
            //offer soda and mark the field
            ticket.surpriseCollected = true;
            //soda exchange logic
            //lets take the ticket no as a random number 
            ticket.surpriseExchanged = true;
            message = "We are happy to serve you";
        }
        emit SurpriseEvent(msg.sender, "claimed", message);
    }
}

contract MovieBooking {
    //this will support multiple theatres
    mapping (string => Theatre) theatres;

    function createTheater(string theatreName, string location) public {
        Theatre theatre = new Theatre(theatreName, location);
        theatres[theatreName] = theatre;
    }

    function addMovie(string theatre, string movie) public {
        theatres[theatre].addMovie(movie);
    }

    function createShow(string theatre) public {
        theatres[theatre].createNewShow();
    }

    function bookTicket(string theatre, string movie, uint8 window, Theatre.ShowType show, string cname, string cphone, uint8 persons) public {
        theatres[theatre].bookTicket(movie, window, show, cname, cphone, persons);
    }
}