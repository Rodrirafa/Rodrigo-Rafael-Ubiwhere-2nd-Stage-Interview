// version
pragma solidity >=0.4.16 <0.7.0;

/// @author Rodrigo Rafael 
/// 22/04/2020

/// @title abstract contract that can be used to implement a similar system
abstract contract ActivityControlAbs{
    address public manager; //the address of the manager of workers. Can add workers
    
    //list of activities for each address, each address corresponds to a worker
    mapping (address => Activity[]) internal activities;
    // map for workers; each worker has one and only one address
    mapping (address => Worker)  internal workers;  
    Activity[] public arrayActivities;
    
    constructor(address _address) public {
        manager = _address;
    }
    
    function createWorker(address addr, uint256 id, string memory name) virtual public;
    function removeWorker(address addr) virtual public;
    
    function addActivity(
        Date startDate,
        Date finishDate,
        string memory description,
        ActivityType activityType
    )
        virtual internal;
    
}
/// @title Control of Activities and Workers for physiotherapy 
contract ActivityControl is ActivityControlAbs{
    // call the "mother" contract's constructor
    constructor() ActivityControlAbs(msg.sender) public {} 
    
    /// @dev Creates a worker for the specified address, with the worker's id and name
    /// @param addr the address of the worker - considering that the manager creates an account
    /// for their address and public-private keys
    /// @param id the id of the worker
    /// @param name of the worker
    function createWorker(address addr, uint256 id, string memory name) override public {
        // Required that the person calling this function is the manager
        require(msg.sender == manager);
        // Create worker with the given params
        Worker worker = new Worker(id,name);
        // Associate worker with the address given
        workers[addr] = worker;
    }
    
    /// @dev removes a worker
    /// @param addr address 
    function removeWorker(address addr) override public{
        require(msg.sender == manager);
        workers[addr] = Worker(0x0);
    }
    
    /// @dev Adds an activity to the list of activities of the worker who is calling the function
    /// @param startDate the date in which the activity is to begin
    /// @param finishDate the date in which the activity is to end
    /// @param description a description of the activity
    /// @param activityType the type of activity. Can be Ultrasound, 
    /// Current or Aerosol, or any other type that extends ActivityType
    function addActivity (
        Date startDate,
        Date finishDate,
        string memory description,
        ActivityType activityType
    )
        override internal 
    {
        // Required that worker has been registered by manager
        require(workers[msg.sender] != Worker(0x0)); 
        // Add new activity to list of activities of the worker that called the function
        Activity newActivity = new  Activity(startDate,finishDate,description,activityType);
        // Also add it to public array that anyone can see
        activities[msg.sender].push(newActivity); 
        arrayActivities.push(newActivity);
    }
    
    /// @dev Adds an aerosol, calls addActivity
    /// @param startDay the day of the start Date
    /// @param startMonth the month of the start Date
    /// @param startYear the year of the start Date
    /// @param endDay the day of the end Date
    /// @param endMonth the month of the end Date
    /// @param endYear the year of the end Date
    /// @param description a description of the activity 
    /// @param quantity property of Aerosol activity
    /// @param ventilan property of Aerosol activity
    function addAerosol(
        uint256 startDay,
        uint256 startMonth,
        uint256 startYear,
        uint256 endDay,
        uint256 endMonth,
        uint256 endYear,
        string memory description,
        uint256 quantity,
        uint256 ventilan
    )
        public 
    {
        addActivity(new Date(startDay,startMonth,startYear),
                    new Date(endDay,endMonth,endYear),
                    description,
                    new Aerosol(quantity,ventilan)
                    );
    }
    
    /// @dev Adds an current, calls addActivity
    /// @param startDay the day of the start Date
    /// @param startMonth the month of the start Date
    /// @param startYear the year of the start Date
    /// @param endDay the day of the end Date
    /// @param endMonth the month of the end Date
    /// @param endYear the year of the end Date
    /// @param description a description of the activity 
    /// @param diameter property of Current activity
    /// @param humidity property of Current activity
    function addCurrent(
        uint256 startDay,
        uint256 startMonth,
        uint256 startYear,
        uint256 endDay,
        uint256 endMonth,
        uint256 endYear,
        string memory description,
        uint256 diameter,
        uint256 humidity
    )
        public
    {
         addActivity(new Date(startDay,startMonth,startYear),
                    new Date(endDay,endMonth,endYear),
                    description,
                    new Current(diameter,humidity));
    }
    
    /// @dev Adds an ultrasound, calls addActivity
    /// @param startDay the day of the start Date
    /// @param startMonth the month of the start Date
    /// @param startYear the year of the start Date
    /// @param endDay the day of the end Date
    /// @param endMonth the month of the end Date
    /// @param endYear the year of the end Date
    /// @param description a description of the activity 
    /// @param power property of Ultrasound activity
    /// @param frequency property of Ultrasound activity
    function addUltrasound(
        uint256 startDay,
        uint256 startMonth,
        uint256 startYear,
        uint256 endDay,
        uint256 endMonth,
        uint256 endYear,
        string memory description,
        uint256 power,
        uint256 frequency
    )
        public
    {
        addActivity(
            new Date(startDay,startMonth,startYear),
            new Date(endDay,endMonth,endYear),
            description,
            new Ultrasound(power,frequency)
        );
    }
    
        
    
}


/// @title Encapsulation of details of activity
contract Activity{
    Date startDate;
    Date finishDate;
    string description;
    ActivityType activityType;
    
    constructor(
        Date start, 
        Date finish, 
        string memory desc, 
        ActivityType typeAct
    ) 
        public 
    {
        startDate = start;
        finishDate = finish;
        description = desc;
        activityType = typeAct;
    }
    
}


/// @title abstract contract that can be used to implement more types of activities 
abstract contract ActivityType{
    function abstractionMaker() virtual public;
}


/// @title Ultrasound is a type of activity
contract Ultrasound is ActivityType{
    uint256 power;
    uint256 frequency;
    
    constructor(uint256 _power, uint256 _frequency) public {
        power = _power;
        frequency = _frequency;
    }
    
    function  abstractionMaker() override public {}
}


/// @title Current is a type of activity
contract Current is ActivityType{ //suposto ser "Correntes"
    uint256 diameter;
    uint256 humidity;
    
    constructor(uint256 _diameter, uint256 _humidity) public {
        diameter = _diameter;
        humidity = _humidity;
    }
    
    function abstractionMaker() override public {}
}


/// @title Aerosol is a type of activity
contract Aerosol is ActivityType{
    uint256 quantity;
    uint256 ventilan;
    
    constructor(uint256 _quantity, uint256 _ventilan) public {
        quantity = _quantity;
        ventilan = _ventilan;
    }
    
    function abstractionMaker() override public {}
}


/// @title contract to encapsulate the information related to a date
contract Date{
    uint256 day;
    uint256 month;
    uint256 year;
    
    constructor(uint256 _day, uint256 _month, uint256 _year) public {
        day = _day;
        month = _month;
        year = _year;
    }
}


/// @title contract to encapsulate the information related to a worker
contract Worker{
    uint256 worker_id; 
    string name;
    
    constructor(uint256 _worker_id, string memory _name) public {
        worker_id = _worker_id;
        name = _name;
    }
}