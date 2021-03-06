# How to swap tokens on MintyDEFI

### Step 1: Grant spending approval to the swap router

[Here's an instruction on how to grant spending approval](https://github.com/EUBIToken/MintyDEFI/blob/main/approve.md)

NOTE: despite the fact that tokens deployed via MintyDEFI are called ERC-223 tokens, they have full backward compartiability for ERC-20 Spending Approval, since we have to specify which token are we swapping to. Also, you only need to grant spending approval on the first time you swap from any tokens. For example, if you swap EUBI for LIBAS, and then swap EUBI for 1000x, you only need to grant spending approval for EUBI on the first transaction.

[It's safe to grant unlimited spending approval due to this safety check in the code](https://github.com/EUBIToken/MintyDEFI/blob/main/MintMEUniswapRouter.sol#L173)

address: 0x0ed0de66e3b5cb657fdb271dc4df3f679cffdc3a

NOTE: the address used to be 0xfb5098f705770fa9f003ac177f49c137932a5219, until we decided to add an extra feature.

value: 115792089237316195423570985008687907853269984665640564039457584007913129639935 raw units

### Step 2: Access the smart contract

![image](https://user-images.githubusercontent.com/55774978/123363010-dda29900-d59b-11eb-9daf-389824e6ad9a.png)

The contract's address is 0x0ed0de66e3b5cb657fdb271dc4df3f679cffdc3a

[you can copy and paste this ABI/JSON interface over](https://raw.githubusercontent.com/EUBIToken/MintyDEFI/main/MintMEUniswapRouter.json)

### Step 3: Enter the information

![image](https://user-images.githubusercontent.com/55774978/123363582-0a0ae500-d59d-11eb-94cd-abbdd10bdb8b.png)

FromToken and ToTokens should be the token contract addresses of which token are you swapping from and which token are you swapping to. If no Uniswap V2 pairs exist for those 2 tokens, the transaction will fail harmlessly. AmountIn should be the number of raw units of tokens you want to send to Uniswap V2. The router will do it's best to get you the best possible rate or exchange.

NOTE: the [ethereum unit converter](https://eth-converter.com/extended-converter.html) can convert between decimal units and raw units. As you see, we are swapping 1 TEST token for some MDFI tokens.

![image](https://user-images.githubusercontent.com/55774978/123363952-c795d800-d59d-11eb-97bf-8e089784bb4a.png)

It is also recommended that you pre-calculate how many tokens you are getting before submitting the transaction.

![image](https://user-images.githubusercontent.com/55774978/123571750-19846b00-d7f5-11eb-8ad1-cbb6a05f0740.png)


### Step 4: Write and confirm the transaction

![image](https://user-images.githubusercontent.com/55774978/123364007-dda39880-d59d-11eb-9ee3-99c32bbdaeb8.png)

You'll need some MintME to pay for gas when swapping tokens.
