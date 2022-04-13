pragma solidity 0.8.11;
// SPDX-License-Identifier: None


// 𝕓𝕪 @𝕖𝕧𝕞_𝕝𝕒𝕓𝕤 & @𝕕𝕚𝕞𝕚𝕣𝕖𝕒𝕕𝕤𝕥𝕙𝕚𝕟𝕘𝕤 (𝕋𝕨𝕚𝕥𝕥𝕖𝕣)

/*
Created based on a token echange of PERMIES 0xf9c12bd715df34c7850766a48178648ac0cb200d 
THIS IMPLEMENTATION IS NOT AFFILIATED AND IS BY NO MEANS VALIDATED BY THE PERMIES TEAM
*/

import "./Permies.sol";


contract trustlessTokenSwap{

    address internal constant TOKEN_CONTRACT_ADMIN = 0x3e2d2199Ed8a2f2e588E75b6b5eB6C01F49C44aC; // permiesnft.eth

    address internal tokenHolderA;
    address internal tokenHolderB;
    address payable internal tokenContractAddress = payable(0xF9C12BD715Df34c7850766A48178648AC0cB200d); // permies contract
    uint internal lockTime;
    uint internal swapTime;
    uint internal tokensDeposited;
    mapping (address => uint) private addressToToken;
    address internal firstAddressOfSwap;
    bool internal lockedForSwap;

    constructor(){
    }

    modifier onlyWhenContractLocked(){
        require(lockedForSwap, "Contract needs to be locked first.");
        _;
    }

    modifier onlyCalledTwice(){
        require(tokensDeposited < 2, "Max amount of tokens have now been deposited.");
        _;
    }

    modifier onlyNewAddress(address _address){
        require(_address != firstAddressOfSwap, "Address that deposited first token cannot deposit again.");
        _;
    }

    modifier onlyAfterDeposit(){
        require(tokensDeposited > 0, "No tokens have yet been deposited.");
        _;
    }

    modifier onlyTokenOwners(){
        require(addressToToken[msg.sender] != 0, "This address has not deposited a token.");
        _;
    }

    modifier onlyBeforeSwapLock(){
        require(block.timestamp < swapTime - 600, "Tokens are now locked for the swap to take place.");
        _;
    }

    modifier onlyAfterSwapTime(){
        require(block.timestamp >= swapTime, "Swap has not yet occurred.");
        _;
    }

    modifier onlyAfterSwapDeadline(){
        require(block.timestamp >= lockTime + 86400, "Swap deadline has not been reached");
        _;
    }

    modifier onlyAdmin(){
        require(msg.sender == TOKEN_CONTRACT_ADMIN);
        _;
    }

    // Locks the contract for use by the two addresses only
    function lockForSwap(address _tokenHolderA, address _tokenHolderB) public {
        lockedForSwap = true;
        tokenHolderA = _tokenHolderA;
        tokenHolderB = _tokenHolderB;
        lockTime =  block.timestamp;
        swapTime = lockTime + 3600; // 1 hour
    }

    // Allows addresses to deposit their tokens
    function depositToken(uint256 _tokenId) public onlyWhenContractLocked() onlyCalledTwice() onlyNewAddress(msg.sender) onlyBeforeSwapLock(){
        Permies permiesContract = Permies(tokenContractAddress);
        permiesContract.transferFrom(msg.sender, tokenContractAddress, _tokenId);
        if (tokensDeposited == 0){
            firstAddressOfSwap = msg.sender;
        }
        tokensDeposited += 1;
        addressToToken[msg.sender] = _tokenId + 1; // +1 to ensure that tokenId stored is non zero as we want to use zero as empty
    }

    // Allows addresses to withdraw their OWN token, if they see that oth
    function withdrawOwnToken() public onlyWhenContractLocked() onlyAfterDeposit() onlyTokenOwners() {
        Permies permiesContract = Permies(tokenContractAddress);
        if (msg.sender == tokenHolderA){
            permiesContract.transferFrom(tokenContractAddress, tokenHolderA, addressToToken[tokenHolderA]-1);
            if (addressToToken[tokenHolderB]>0){
                permiesContract.transferFrom(tokenContractAddress, tokenHolderB, addressToToken[tokenHolderB]-1);
            }
        }
        else{
            permiesContract.transferFrom(tokenContractAddress, tokenHolderB, addressToToken[tokenHolderB]-1);
            if (addressToToken[tokenHolderA]>0){
                permiesContract.transferFrom(tokenContractAddress, tokenHolderA, addressToToken[tokenHolderA]-1);
            }
        releaseSwapLock();
        }
    }

    // Swaps the tokens 
    function withdrawNewToken() public onlyWhenContractLocked() onlyAfterSwapTime() onlyTokenOwners() {
        Permies permiesContract = Permies(tokenContractAddress);
        permiesContract.transferFrom(tokenContractAddress, tokenHolderB, addressToToken[tokenHolderA]-1);
        permiesContract.transferFrom(tokenContractAddress, tokenHolderA, addressToToken[tokenHolderB]-1);
        releaseSwapLock();
    }

    // revert to starting state
    function releaseSwapLock() internal {
        addressToToken[tokenHolderA] = 0;
        addressToToken[tokenHolderB] = 0;
        tokenHolderA = address(0);
        tokenHolderB = address(0);
        tokensDeposited = 0;
        lockedForSwap = false;
    }

    // Admin can release the lock if previous owners have not completed transaction in given time
    function AmdminReleaseSwapLock() public onlyAdmin() onlyWhenContractLocked()  onlyAfterSwapDeadline() {
        // maybe send tokens back?
        releaseSwapLock();
    }

}


/* Testing
1. Can users lock the contract?
2. Can users deposit a token to a contract?
3. Can users view the tokens that have been deposited to the contract?
4. Can users withdraw their own tokens?
5. Can users withdraw the other tokens before the time? (they should not)
6. Can users withdraw the other tokens after the time? (they should)
7. Can users deposit more than one token?
8. Can users deposit token when unlocked?
9. Can an admin obtain the tokens when locked?
10. Can an admin release the lock during the hour?
11. Can the admin release the lock between 1 and 24 hours?
12. Can the admin release the lock after 24 hours?
*/ 







