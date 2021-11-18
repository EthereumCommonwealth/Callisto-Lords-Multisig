// SPDX-License-Identifier: No License (None)
pragma solidity ^0.8.0;

contract CallistoMultisig {
    
    struct Tx
    {
        address to;
        uint256 value;
        bytes   data;
        
        uint256 proposed_timestamp;
        bool    executed;
        mapping (address => bool) signed_by;
        
        uint256 num_approvals;
    }
    
    mapping (uint256 => Tx)   public txs;
    mapping (address => bool) public owner;
    uint256 public num_owners;
    uint256 num_TXs                = 0;
    uint256 public execution_delay = 10 days;
    
    modifier onlyOwner
    {
        require(owner[msg.sender], "Only owner is allowed to do this");
        _;
    }
    
    constructor (address _owner1, address _owner2) {
        owner[_owner1] = true;
        owner[_owner2] = true;
        num_owners     = 2;
    }
    
    // Allow it to receive ERC223 tokens and Funds transfers.
    receive() external payable { }
    fallback() external payable { }
    
    function executeTx(uint256 _txID) public onlyOwner
    {
        require(txAllowed(_txID), "Tx is not allowed");
        
        address _destination = txs[_txID].to;
        _destination.call{value:txs[_txID].value}(txs[_txID].data);
        
        txs[_txID].executed = true;
    }
    
    function proposeTx(address _to, uint256 _valueInWEI, bytes calldata _data) public onlyOwner
    {
        num_TXs++;
        // Setup Tx values.
        txs[num_TXs].to    = _to;
        txs[num_TXs].value = _valueInWEI;
        txs[num_TXs].data  = _data;
        
        // Setup system values to keep track on Tx validity and voting.
        txs[num_TXs].proposed_timestamp    = block.timestamp;
        txs[num_TXs].signed_by[msg.sender] = true;
        txs[num_TXs].num_approvals         = 1; // Well, the one who proposes it approves it obviously.
    }
    
    function rejectTx(uint256 _txID) public onlyOwner
    {
        txs[_txID].signed_by[msg.sender] = true;
        txs[_txID].executed              = true; // Mark Tx as already-executed
    }
    
    function approveTx(uint256 _txID) public onlyOwner
    {
        require(!txs[_txID].signed_by[msg.sender], "This Tx is already signed by this owner");
        txs[_txID].signed_by[msg.sender] = true;
        txs[_txID].num_approvals++;
        if(txs[_txID].num_approvals == num_owners)
        {
            executeTx(_txID);
        }
    }
    
    function txAllowed(uint256 _txID) public view returns (bool)
    {
        /**
         * Allows Tx to be executed if ALL owners signed it
         * or it was proposed 10 days ago and no one voted to reject it.
         */
        require(!txs[_txID].executed, "Tx already executed or rejected");
        require(txs[_txID].num_approvals == num_owners || block.timestamp >= txs[_txID].proposed_timestamp + execution_delay, "Tx is not approved by at least one of owners");
        return true;
    }
    
    function addOwner(address _owner) public
    {
        require(msg.sender == address(this), "Only internal voting can introduce new owners");
        owner[_owner] = true;
        num_owners++;
    }
    
    function removeOwner(address _owner) public
    {
        require(msg.sender == address(this), "Only internal voting can remove existing owners");
        owner[_owner] = false;
        num_owners--;
    }
}
