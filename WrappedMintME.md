# Wrapped MintME: a workaround for the MintME bug that killed EUBIng on MintME and a way to use MintME with MintyDEFI

## Problem

MintME mis-implemented the Solidity send() and transfer() function

## Solution

Send MintME by using selfdestruct()/suicide() instead of send()/transfer(), and create the Wrapped MintME token

## Smart contract details

ABI/JSON interface URL: https://raw.githubusercontent.com/EUBIToken/MintyDEFI/main/WrappedMintME.json

Token contract address: 0x4a89e12f7109c9b27f50eb18d542f84c2ca5c0ec

## Wrapping

### Step 1: Input the token address and ABI/JSON interface into your wallet's interact menu

![image](https://user-images.githubusercontent.com/55774978/124736483-3df0ed80-df41-11eb-8641-1704759c00ee.png)

### Step 2: If you are wrapping MintME for the first time from any addresses, you need to register your wallet

![image](https://user-images.githubusercontent.com/55774978/124736829-97f1b300-df41-11eb-8389-c07c807a501c.png)

## Step 3: Get your one-time deposit address

![image](https://user-images.githubusercontent.com/55774978/124737122-dc7d4e80-df41-11eb-9c67-b39a8ef1e897.png)

NOTE: Addr should be your wallet address

## Step 4: Send your MintME over

![image](https://user-images.githubusercontent.com/55774978/124737525-3b42c800-df42-11eb-9b31-2673aa342a76.png)

NOTE: You must send exactly 100 MintME, and from the same wallet you retrieved the one-time deposit address for, otherwise, the transaction will revert. Due to a bug in the MintME web wallet, you must enter the MintME amount before you enter the one-time deposit address. After you sent the transaction, the one-time deposit address will stop accepting MintME and a new one will be generated for your wallet. Also, due to the limitations of the workaround, MintME can only be wrapped or unwrapped in batches of 100 MintME.

## Unwrapping

### Step 1: Input the token address and ABI/JSON interface into your wallet's interact menu

![image](https://user-images.githubusercontent.com/55774978/124736483-3df0ed80-df41-11eb-8641-1704759c00ee.png)

### Step 2: Unwrap your MintME

![image](https://user-images.githubusercontent.com/55774978/124738569-3f231a00-df43-11eb-9326-61c8946edcd4.png)

NOTE: MintME must be unwrapped in batches of 100 MintME, but multiple batches can be unwrapped in one transaction. Set rounds to the number of batches you want to unwrap (e.g 1 round for 100 MintME, 2 rounds for 200 MintME).
