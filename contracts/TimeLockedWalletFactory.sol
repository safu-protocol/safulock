pragma solidity ^0.8.0;

import "./TimeLockedWallet.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract TimeLockedWalletFactory is Ownable {
    mapping(address => address[]) wallets;
    uint256 private _bnbFee = 0;

    // Get BNB fee required to create a lock
    function bnbFee() public view returns (uint256) {
        return _bnbFee;
    }

    // Modify BNB fee required to create a lock
    function setBnbFee(uint256 fee) public onlyOwner {
        _bnbFee = fee;
    }

    // Return all timelocked wallets for a specific user
    function getWallets(address _user) public view returns (address[] memory) {
        return wallets[_user];
    }

    function newTimeLockedWallet(address _owner, uint256 _unlockDate)
        public
        payable
        returns (address wallet)
    {

        require(
            msg.value >= bnbFee(),
            "Lock fee too small!"
        );

        // Tranfer the lock fee
        payable(owner()).transfer(msg.value);

        // Create new wallet.
        wallet = address(new TimeLockedWallet(msg.sender, _owner, _unlockDate));

        // Add wallet to sender's wallets.
        wallets[msg.sender].push(wallet);

        // If owner is the same as sender then add wallet to sender's wallets too.
        if (msg.sender != _owner) {
            wallets[_owner].push(wallet);
        }

        // Emit event.
        emit Created(wallet, msg.sender, _owner, block.timestamp, _unlockDate, msg.value);
    }

    // Prevents accidental sending of ether to the factory
    receive() external payable {
        revert();
    }

    event Created(
        address wallet,
        address from,
        address to,
        uint256 createdAt,
        uint256 unlockDate,
        uint256 amount
    );
}
