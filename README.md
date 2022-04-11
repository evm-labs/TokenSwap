### TokenSwap
Allows owners of ERC721 tokens to swap NFTs one-for-one

### How it works
1. One of the two parties interested in making the swap calls the lockForSwap(address _tokenHolderA, address _tokenHolderB) method, which blocks other users from using the contract.
2. The contract locks for 1 hour while only these two parties can call the methods.
3. Both parties can go ahead and deposit their tokens over the next 50 minutes by calling the depositToken(uint256 _tokenId) method.
4. The tokens are deposited to the original contract from which they were minted, but no one can interact with them for that hour
5. The deposits then lock for 10 minutes, where the two parties can ensure that the other party has deposited the correct token.
6. In those 10 minutes, both parties are allowed to cancel the transaction by calling the withdrawOwnToken() method.
7. By doing so, all parties that had deposited a token will receive it back in their wallet. Gas cost is incurred by the person calling the withdrawal method.
8. After the 1 hour, either party can call the withdrawNewToken() method which will execute the swap.
9. If the swap is not executed in 24hours, the admin get release the lock. The tokens can either remain on the contract or be returned to the users.

### Note:
1. The Permies NFT was used as an example for the development of this contract.
2. The contract owner of which parties want to swap tokens is the best party to deploy this contract on-chain. The reason is that as trustless as this swap may be, an admin is necessary in case the two parties keep the contract locked for longer


### DISCLAIMER
##### THIS IMPLEMENTATION IS NOT AFFILIATED AND IS BY NO MEANS VALIDATED BY THE PERMIES TEAM
