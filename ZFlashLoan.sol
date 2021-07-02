pragma solidity =0.4.17;
contract ERC20Interface{
        function transferFrom(address from, address to, uint256 value) external;
        function balanceOf(address owner) external view;
}
contract ZFlashLoanBorrower{
        function onLoanReceived(uint256 amount) external;
}
contract ZFlashLoanLender{
        function borrow(uint256 amount) external;
}
contract ZFlashLoanLenderIMPL is ZFlashLoanLender{
        function borrow(uint256 amount) external{
                address lender = 0x83da448ae434c29af349508d03be2a50d5d37cbc; //Jessie Lesbian
                ERC20Interface token = ERC20Interface(0x8AFA1b7a8534D519CB04F4075D3189DF8a6738C1); //EUBI
                //Get lender's balance
                uint256 balance = token.balanceOf(lender);
                //Send loan amount to borrower
                require(token.transferFrom(lender, msg.sender, amount));
                //Call borrower
                ZFlashLoanBorrower(msg.sender).onLoanReceived(amount);
                //If the borrower fails to repay the flash loan, then revert the transaction
                require(token.balanceOf(lender) >= balance);
                //It's impossible to default on a flash loan, because if you don't repay a flash loan
                //then you don't get it in the first place
        }
}
