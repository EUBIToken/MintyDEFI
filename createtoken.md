# How to create a token on MintyDEFI

### Step 1: input the contract address and ABI/JSON Interface into your wallet's interact menu

Contract address: 0x77d062eb1dd9fb48a9875c73abf6c6d247e91b39

[file containing contract ABI](https://raw.githubusercontent.com/EUBIToken/MintyDEFI/main/CentralFactory.json)

![image](https://user-images.githubusercontent.com/55774978/123063868-f8f49380-d437-11eb-81ca-afd4e93d51e6.png)

### Step 2: enter name and symbol for your token

![image](https://user-images.githubusercontent.com/55774978/123064187-3f49f280-d438-11eb-983e-1147b5faa01c.png)

NOTE: MintyDEFI DOES NOT allow token name/symbol collisions or tokens symbols longer than 5 characters

### Steep 3: write and confirm your transaction

![image](https://user-images.githubusercontent.com/55774978/123064450-7a4c2600-d438-11eb-96ec-d35784b554b2.png)

Make sure that you have some MintME for gas!

### Step 4: retrieve the address of your token

![image](https://user-images.githubusercontent.com/55774978/123064637-a5cf1080-d438-11eb-8477-8effa1142189.png)

## NOTES

1. The wallet used to create the token receives a 10,000,000 token starting balance.
2. The tokens created here are ERC-223 tokens with extended token metadata and spending approval support to be fully backward compartiable with ERC-20.
3. Each newly created token on MintyDEFI is automatically listed on a Token-MDFI Uniswap V2 pair
