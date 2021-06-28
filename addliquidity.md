# How to add liquidity to an Uniswap V2 pair on MintyDEFI

### Step 1: grant spending approval to the liquidity manager

[Here's an instruction on how to grant spending approval](https://github.com/EUBIToken/MintyDEFI/blob/main/approve.md)

NOTE: despite the fact that tokens deployed via MintyDEFI are called ERC-223 tokens, they have full backward compartiability for ERC-20 Spending Approval, since we have to send 2 diffrent tokens to a smart contract at once here. Also, you only need to grant spending approval when adding liquidity for the first time.

address: 0x16d83191c561fa6ecdb91b0e0a9e0b3642d0e80d

value: 115792089237316195423570985008687907853269984665640564039457584007913129639935 raw units

[It's safe to grant unlimited spending approval due to this safety check in the code](https://github.com/EUBIToken/MintyDEFI/blob/main/MintMEUniswapLiquidityManager.sol#L227)

### Step 2: Put the JSON/ABI and contract address into your wallet

Contract address: 0x16d83191c561fa6ecdb91b0e0a9e0b3642d0e80d

[Here's a file containing the JSON/ABI](https://raw.githubusercontent.com/EUBIToken/MintyDEFI/main/LiquidityManager.json)

![image](https://user-images.githubusercontent.com/55774978/123067127-e891e800-d43a-11eb-8fd6-637afdf2988f.png)

### Step 3: enter the details into the liquidity manager contract

TokenA and TokenB should be token addresses for both tokens. If no Uniswap V2 pair exists for the aforementioned tokens, then the Uniswap V2 pair will be automatically created.

AmountADesired and AmountBDesired should be the maximum amount of raw units you want to provide as liquidity for each tokens

![image](https://user-images.githubusercontent.com/55774978/123067800-808fd180-d43b-11eb-8ea4-f46c1f55e1fc.png)

You can use the [extended ethereum unit converter](https://eth-converter.com/extended-converter.html) if you need help with raw unit conversion. In this case, we are adding 1.2 tokens of both tokens to the liquidity pool.

![image](https://user-images.githubusercontent.com/55774978/123067646-5c33f500-d43b-11eb-8cc2-aa39395472de.png)

### Step 4: confirm the transaction, and you're now officially a liquidity provider for MintyDEFI.

![image](https://user-images.githubusercontent.com/55774978/123068124-ce0c3e80-d43b-11eb-96ab-996c3d7b8a69.png)

NOTE: Liquidity pool tokens can be redeemed to get your liquidity provision investment back, along with any profits/losses. Liquidity pool tokens have the same contract address as the underlying Uniswap V2 pair, and since they are ERC-223 tokens, they can be sent straight back to 0x16d83191c561fa6ecdb91b0e0a9e0b3642d0e80d for redemption.

Here's how to get the Uniswap V2 pair address for an Uniswap V2 pair between 2 tokens

![image](https://user-images.githubusercontent.com/55774978/123069745-49222480-d43d-11eb-81a7-ced0160a5b92.png)

Contract Address: 0x77d062eb1dd9fb48a9875c73abf6c6d247e91b39

[file containing contract ABI](https://raw.githubusercontent.com/EUBIToken/MintyDEFI/main/CentralFactory.json)
