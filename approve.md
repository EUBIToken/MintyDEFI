# How to add an approved spender for an ERC-20 token

Step 1 - get the token contract address

![image](https://user-images.githubusercontent.com/55774978/122696803-2988d180-d26e-11eb-98d1-eec5b902ec2d.png)

Step 2 - input the token address and ABI/JSON Interface into your wallet's interact menu

![image](https://user-images.githubusercontent.com/55774978/122696981-943a0d00-d26e-11eb-89b5-1dababcee2d7.png)

![image](https://user-images.githubusercontent.com/55774978/122697074-bf246100-d26e-11eb-933c-050f921f71dc.png)

[you can copy and paste this default ERC-20 ABI/JSON Interface over, since it works for all ERC-20 tokens](https://raw.githubusercontent.com/EUBIToken/LLToken/main/IERC20.json)

Step 3 - set spending allowance

![image](https://user-images.githubusercontent.com/55774978/122697163-f3981d00-d26e-11eb-8004-e12b7ff646aa.png)

NOTE: Set spender to the address you want to grant spending allowance to, and value to the number of raw units you want to grant.

For example, 1200000000000 raw units would be 1.2 EUBI.

![image](https://user-images.githubusercontent.com/55774978/122697417-7a4cfa00-d26f-11eb-9879-55482136c7b0.png)

[You may find this tool useful when converting from and to raw units](https://eth-converter.com/extended-converter.html)

Since EUBI have 12 decimal points, use the szabo field.

Set allowance to 115792089237316195423570985008687907853269984665640564039457584007913129639935 for unlimited spending limit.

Finaly, confirm the transaction. Since this operation is state mutating, you'll need some MintME for gas.

![image](https://user-images.githubusercontent.com/55774978/122697707-1840c480-d270-11eb-8520-d33659503865.png)
