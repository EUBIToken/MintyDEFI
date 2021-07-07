pragma solidity =0.4.17;
library SafeMath {
	function add(uint x, uint y) internal pure returns (uint z) {
		require((z = x + y) >= x);
	}

	function sub(uint x, uint y) internal pure returns (uint z) {
		require((z = x - y) <= x);
	}

	function mul(uint x, uint y) internal pure returns (uint z) {
		require(y == 0 || (z = x * y) / y == x);
	}
}
contract IERC223Recipient {
	function tokenFallback(address _from, uint _value, bytes memory _data) public;
}
contract DepositAddressOwner{
	function deposited() external;
}
contract IDepositAddress{
	function getDepositor() external view returns (address);
	function WithdrawTo(address withdrawee) external;
}
contract DepositAddress is IDepositAddress{
	address private owner;
	address private depositor;
	function DepositAddress(address _depositor) public{
		owner = msg.sender;
		depositor = _depositor;
	}
	function WithdrawTo(address withdrawee) external{
		require(msg.sender == owner);
		selfdestruct(withdrawee);
	}
	function getDepositor() external view returns (address){
		return depositor;
	}
	function() external payable{
		require(msg.sender == depositor && msg.value == 1 ether && address(this).balance == 1 ether);
		DepositAddressOwner(owner).deposited();
	}
}
contract WrappedMintME is DepositAddressOwner{
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	using SafeMath for uint256;
	mapping (address => uint256) internal _balances;
	mapping (address => mapping (address => uint256)) private _allowed;
	uint256 internal _totalSupply;
	function totalSupply() external view returns (uint256) {
		return _totalSupply;
	}
	function balanceOf(address owner) external view returns (uint256) {
		return _balances[owner];
	}
	function allowance(address owner, address spender) external view returns (uint256) {
		return _allowed[owner][spender];
	}
	function transfer(address to, uint256 value) external returns (bool) {
		bytes memory empty = hex"00000000";
		_transfer(msg.sender, to, value, empty);
		return true;
	}
	function transfer(address to, uint256 value, bytes memory data) public returns (bool) {
		_transfer(msg.sender, to, value, data);
		return true;
	}
	function approve(address spender, uint256 value) external returns (bool) {
		require(spender != address(0));
		_allowed[msg.sender][spender] = value;
		Approval(msg.sender, spender, value);
		return true;
	}
	function transferFrom(address from, address to, uint256 value) external returns (bool) {
		require(from != address(0));
		_allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
		bytes memory empty = hex"00000000";
		_transfer(from, to, value, empty);
		return true;
	}
	function transferFrom(address from, address to, uint256 value, bytes memory data) public returns (bool) {
		require(from != address(0));
		_allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
		_transfer(from, to, value, data);
		return true;
	}
	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		require(spender != address(0));
		_allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
		Approval(msg.sender, spender, _allowed[msg.sender][spender]);
		return true;
	}
	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		require(spender != address(0));
		_allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
		Approval(msg.sender, spender, _allowed[msg.sender][spender]);
		return true;
	}
	function isContract(address account) private view returns (bool) {
		uint256 size;
		// solhint-disable-next-line no-inline-assembly
		assembly { size := extcodesize(account) }
		return size > 0;
	}
	function _transfer(address from, address to, uint256 value, bytes memory data) internal {
		require(to != address(0));
		_balances[from] = _balances[from].sub(value);
		_balances[to] = _balances[to].add(value);
		if(isContract(to)) {
			IERC223Recipient receiver = IERC223Recipient(to);
			receiver.tokenFallback(msg.sender, value, data);
		}
		Transfer(from, to, value);
	}
	function name() external pure returns (string) {
		return "Wrapped MintME";
	}
	function symbol() external pure returns (string) {
		return "WMNT";
	}
	function decimals() external pure returns (uint8) {
		return 12;
	}
	mapping(address => address) private oneTimeDepositAddresses;
	mapping(address => uint256) private isOTDA;
	mapping(uint256 => address) private OTDAQueue;
	uint256 private OTDAQueueCounter;
	uint256 private OTDARedeemQueueCounter;
	function getOneTimeDepositAddress() external view returns (address){
		return oneTimeDepositAddresses[msg.sender];
	}
	function getOneTimeDepositAddressFor(address addr) external view returns (address){
		return oneTimeDepositAddresses[addr];
	}
	function firstTimeUse() external{
		address otda = oneTimeDepositAddresses[msg.sender];
		require(otda == address(0));
		otda = new DepositAddress(msg.sender);
		oneTimeDepositAddresses[msg.sender] = otda;
		isOTDA[otda] = 1;
	}
	function deposited() external{
		require(isOTDA[msg.sender] == 1);
		OTDAQueue[OTDAQueueCounter++] = msg.sender;
		_totalSupply = _totalSupply.add(100 szabo);
		address account = IDepositAddress(msg.sender).getDepositor();
		_balances[account] = _balances[account].add(100 szabo);
		account = new DepositAddress(msg.sender);
		oneTimeDepositAddresses[msg.sender] = account;
		isOTDA[account] = 1;
		Transfer(address(0), account, 100 szabo);
	}
	function unwrap(uint256 rounds) external{
		uint256 value = rounds.mul(100 szabo);
		_totalSupply = _totalSupply.sub(value);
		_balances[msg.sender] = _balances[msg.sender].sub(value);
		Transfer(msg.sender, address(0), value);
		value = OTDARedeemQueueCounter;
		for(uint256 i = 0; i < rounds; i++){
			IDepositAddress(OTDAQueue[value + i]).WithdrawTo(msg.sender);
		}
		OTDARedeemQueueCounter = value + rounds;
	}
	function unwrapTo(address destination, uint256 rounds) external{
		uint256 value = rounds.mul(100 szabo);
		_totalSupply = _totalSupply.sub(value);
		_balances[msg.sender] = _balances[msg.sender].sub(value);
		Transfer(msg.sender, address(0), value);
		value = OTDARedeemQueueCounter;
		for(uint256 i = 0; i < rounds; i++){
			IDepositAddress(OTDAQueue[value + i]).WithdrawTo(destination);
		}
		OTDARedeemQueueCounter = value + rounds;
	}
}
