pragma solidity ^0.4.0;

contract SuperContract {

    address public admin;

    enum  State { Undefined, New, Accepted, Paid, Suspended, Locked, Finished }

    struct Loan {
        bytes32 name;
        address borrower;
        uint amount; //Выданная сумма - 10000
        uint current; //Выплачено - 9000
        uint quantityOfPeriods; //Кол-во периодов - 10
        uint currentIteration;
        uint period; //Период 
        uint time; //
        uint start; //Дата начала
        uint finish;
        State status;
    }
    
    Loan loan;


    event CreditNew(address borrower, uint amount, uint time);
    event AcceptedLoan(address borrower);
    event ActivatedLoan(address borrower, bytes key);
    event Pay(address from, uint amount);
    event ChangeStatus(address who, State status);
    event Withdrawal(address _who, uint refund);

    modifier onlyAdmin() {
        require (msg.sender == admin);
        _;
    }


    modifier onlyBank() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyBorrower() {
        require(msg.sender == loan.borrower);
        _;
    }

    modifier checkAmount() {
        require(msg.value > loan.amount);
        _;
    }

    function SuperContract() {
        admin = msg.sender;
    }
    
    function initContract(address borrower, uint amount, uint time, uint quantityOfPeriods) onlyBank returns (bool) {
        CreditNew(borrower, amount, time);

        loan.borrower = borrower;
        loan.amount = amount;
        loan.time = time;
        loan.quantityOfPeriods = quantityOfPeriods;
        loan.currentIteration = 0;
        loan.status = State.New;
        
        return true;
        
    }
    
    function acceptLoan() onlyBorrower returns (bool) {

        require(loan.status == State.New);

        AcceptedLoan(msg.sender);
        //ChangeStatus(msg.sender, State.Accepted);

        loan.status = State.Accepted;
        
        return true;
    }

    function activateLoan(address borrower, bytes key) onlyBank returns (bool) {
        require(loan.status == State.Accepted);
        require(loan.borrower == borrower);

        ActivatedLoan(borrower, key);
        //ChangeStatus(borrower, State.Paid);

        loan.status = State.Paid;
        loan.start = now;
        return true;
    }

    function pay() checkAmount onlyBorrower payable returns (bool) {
        Pay(msg.sender, msg.value);
        uint _value = loan.current;
        //Need to add SafeMath

        loan.current = _value + msg.value;

        if (loan.current >= loan.amount) {
            ChangeStatus(msg.sender, State.Finished);
            loan.status = State.Finished;
        }
        
        loan.currentIteration++;
        return true;
    }

    function checkExtend(address _who) constant returns (State status) {
        State currentStatus = loan.status;
 //Нужно прописать проверки
        if (false) {
            ChangeStatus(_who, State.Suspended);
            loan.status = State.Suspended;
        }

        if (false) {
            ChangeStatus(_who, State.Locked);
            loan.status = State.Locked;
        }


        return loan.status;
    }
    function blockAccount(address _who) {}

    function getCurrent() constant returns (uint currentAmount) {
        return loan.current;
    } 
    
    function getStatus() constant returns (State) {
        return loan.status;
    }
    
    function doSuspend() {
        
        ChangeStatus(loan.borrower, State.Suspended);
        loan.status = State.Suspended;
    } 

    function doLock() {
        ChangeStatus(loan.borrower, State.Locked);
        loan.status = State.Locked;
    } 

    function withdraw(address _who) onlyBorrower {
        require(loan.status == State.Finished);
        require(loan.current > loan.amount);

        //Need to add SafeMath
        uint refund = loan.current - loan.amount;

        Withdrawal(_who, refund);
        loan.current = loan.amount;

/*        if (msg.sender.) {

        }
*/
    }


}