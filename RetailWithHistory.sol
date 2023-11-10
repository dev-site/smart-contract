
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RetailPropertyContract {
    address public owner;
    string public propertyAddress;
    uint256 public rentAmount;
    uint256 public leaseDuration;
    uint256 public contractStartDate;
    RentPayment[] public rentHistory;

    struct RentPayment {
        address tenant;
        uint256 amount;
        uint256 timestamp;
    }

    // Events to log important contract activities
    event LeaseStarted(address indexed tenant, uint256 startDate, uint256 duration);
    event RentPaid(address indexed tenant, uint256 amount, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier leaseNotStarted() {
        require(contractStartDate == 0, "Lease has already started");
        _;
    }

    constructor(string memory _propertyAddress, uint256 _rentAmount, uint256 _leaseDuration) {
        owner = msg.sender;
        propertyAddress = _propertyAddress;
        rentAmount = _rentAmount;
        leaseDuration = _leaseDuration;
    }

    function startLease() external onlyOwner leaseNotStarted {
        contractStartDate = block.timestamp;
        emit LeaseStarted(msg.sender, contractStartDate, leaseDuration);
    }

    function payRent() external payable {
        require(msg.value == rentAmount, "Incorrect rent amount");
        require(block.timestamp < contractStartDate + leaseDuration, "Lease has expired");

        // Transfer rent to the owner
        payable(owner).transfer(msg.value);

        // Record rent payment in history
        RentPayment memory payment = RentPayment(msg.sender, msg.value, block.timestamp);
        rentHistory.push(payment);

        emit RentPaid(msg.sender, msg.value, block.timestamp);
    }

    function getRentHistoryCount() external view returns (uint256) {
        return rentHistory.length;
    }

    function getRentPayment(uint256 index) external view returns (address, uint256, uint256) {
        require(index < rentHistory.length, "Index out of range");
        RentPayment memory payment = rentHistory[index];
        return (payment.tenant, payment.amount, payment.timestamp);
    }
}
