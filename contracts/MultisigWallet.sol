// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    struct Transaction {
        address destination;
        uint value;
        bool executed;
        bytes data;
        uint confirmations;
    }

    mapping(uint => mapping(address => bool)) public confirmations;
    Transaction[] public transactions;

    event Deposit(address indexed sender, uint amount);
    event Submission(uint indexed transactionId);
    event Confirmation(address indexed owner, uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactionId < transactions.length, "Transaction does not exist");
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner], "Transaction not confirmed");
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner], "Transaction already confirmed");
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed, "Transaction already executed");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid number of required confirmations");

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        required = _required;
    }

    receive() virtual external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address destination, uint value, bytes memory data)
        public
        onlyOwner
        returns (uint transactionId)
    {
        transactionId = transactions.length;
        transactions.push(Transaction({
            destination: destination,
            value: value,
            executed: false,
            data: data,
            confirmations: 0
        }));
        emit Submission(transactionId);
    }

    function confirmTransaction(uint transactionId)
        public
        onlyOwner
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        transactions[transactionId].confirmations += 1;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function executeTransaction(uint transactionId)
        internal
        onlyOwner
        transactionExists(transactionId)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        Transaction storage txn = transactions[transactionId];

        if (txn.confirmations >= required) {
            txn.executed = true;
            (bool success, ) = txn.destination.call{value: txn.value}(txn.data);
            if (success)
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    function getConfirmations(uint transactionId)
        public
        view
        returns (uint count)
    {
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
        }
    }
}
