// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiSigWallet.sol";

contract FundManager is MultiSigWallet {

    constructor(address[] memory _owners, uint _required) MultiSigWallet(_owners, _required) {
    }

    function deposit() public payable {
        require(msg.value > 0, "No ether sent");
    }

    function submitWithdrawal(address payable to, uint amount) public {
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);
        submitTransaction(address(this), 0, data);
    }

    function executeWithdrawal(uint transactionId) public {
        executeTransaction(transactionId);
    }

    function transfer(address payable to, uint amount) public {
        require(address(this).balance >= amount, "Insufficient balance");
        to.transfer(amount);
    }

    receive() override  external payable {}
}
