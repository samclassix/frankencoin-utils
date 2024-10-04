# Testing

-   [x] Redeem Tokens
-   [x] Redeem NFT
-   [x] Approve PositionManager NFT SC
-   [x] Approve SwapRouter SC
-   [x] Approve Infinity
-   [x] Swap for single input
-   [x] Swap for single output
-   [x] Mint New Position
-   [x] receive nft, transfer
-   [x] receive nft, safeTransfer
-   [x] receive nft, correct implementation
-   [x] receive nft, only owned position (within transfer)
-   [x] receive nft, awareness (deposit mapping)
-   [x] Decrease Liquidity
-   [x] Increase Liquidity
-   [x] Collect Fee (Withdraw: flase)

# Transfer ERC20 and Redeem

![alt text](<Screenshot 2024-10-02 at 6.39.07 PM.png>)

# Transfer ERC721 and Redeem

### Transfer NFT Position to SC

![alt text](<Screenshot 2024-10-03 at 10.41.17 PM.png>)

### Redeem with admin rights from SC

![alt text](<Screenshot 2024-10-03 at 10.43.39 PM.png>)

# Swaps

### Swap Exact Input Single through SC

![alt text](<Screenshot 2024-10-03 at 7.57.41 AM.png>)

### Swap Exact Output Single through SC

![alt text](<Screenshot 2024-10-03 at 7.57.50 AM.png>)

# Create mint

> Deployment No. 3 - 0xaACb94eC5eE4e6742aC4472Fd275569378F0A2B4

https://polygonscan.com/tx/0x76d5bab286491193bb472fdf74783277526c00dc443d7d3b015ecdd939c95789

![alt text](<Screenshot 2024-10-03 at 11.17.58 PM.png>)

# Receive NFT from EOA via SafeTransfer

This will test the correct implementation from ERC721 (IERC721Receiver, onERC721Received)

> https://polygonscan.com/tx/0xd5599599b8af6566cc0803f4a9f2131dbdef8a683fe2af4eb23c36ab1076399f

![alt text](<Screenshot 2024-10-03 at 11.21.30 PM.png>)

# LiquidityController awareness of Transfered ERC721

![alt text](<Screenshot 2024-10-03 at 11.22.06 PM.png>)

# Decrease Liquidity

> https://polygonscan.com/tx/0xbfb366ca049bd102bdeeca0952a60609ffb090d76985569a7bd455c9ca6b6edc

![alt text](<Screenshot 2024-10-04 at 9.33.25 AM.png>)

### Before

![alt text](<Screenshot 2024-10-04 at 9.09.33 AM.png>)

### Tx

![alt text](<Screenshot 2024-10-04 at 9.11.59 AM.png>)

### After

![alt text](<Screenshot 2024-10-04 at 9.10.14 AM.png>)

### Wondering?

Why is there no ERC20 token transfer back to the LiquidityController?

![alt text](<Screenshot 2024-10-04 at 9.24.46 AM.png>)

![alt text](<Screenshot 2024-10-04 at 9.24.53 AM.png>)

# Increase Liquidity

> https://polygonscan.com/tx/0xcfece73327808255b7b219affb441c19aea27a566de463acfc1b57e4572812d0

![alt text](<Screenshot 2024-10-04 at 9.33.21 AM.png>)

![alt text](<Screenshot 2024-10-04 at 9.31.29 AM.png>)

![alt text](<Screenshot 2024-10-04 at 9.32.05 AM.png>)

![alt text](<Screenshot 2024-10-04 at 9.32.16 AM.png>)

![alt text](<Screenshot 2024-10-04 at 9.32.22 AM.png>)

# Collect Fee

> https://polygonscan.com/tx/0xbacb64eaffc1438ddcbe8a8b817606995d4eee81924db2a8c3c524bbef418420#eventlog

![alt text](<Screenshot 2024-10-04 at 9.33.30 AM.png>)

![alt text](<Screenshot 2024-10-04 at 9.26.46 AM.png>)

![alt text](<Screenshot 2024-10-04 at 9.27.03 AM.png>)
