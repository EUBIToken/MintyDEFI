
// File: contracts/interfaces/IUniswapV2Callee.sol

pragma solidity 0.4.17;

interface IUniswapV2Callee {
	function uniswapV2Call(address sender, uint amount0, uint amount1, bytes data) external;
}

// File: contracts/interfaces/IERC20.sol

interface IERC20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address who) external view returns (uint256);

	function allowance(address owner, address spender) external view returns (uint256);

	function transfer(address to, uint256 value) external returns (bool);

	function approve(address spender, uint256 value) external returns (bool);

	function transferFrom(address from, address to, uint256 value) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/libraries/UQ112x112.sol

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
	uint224 constant Q112 = 2**112;

	// encode a uint112 as a UQ112x112
	function encode(uint112 y) internal pure returns (uint224 z) {
		z = uint224(y) * Q112; // never overflows
	}

	// divide a UQ112x112 by a uint112, returning a UQ112x112
	function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
		z = x / uint224(y);
	}
}

// File: contracts/libraries/Math.sol

// a library for performing various math operations

library Math {
	function min(uint x, uint y) internal pure returns (uint z) {
		z = x < y ? x : y;
	}

	// babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
	function sqrt(uint y) internal pure returns (uint z) {
		if (y > 3) {
			z = y;
			uint x = y / 2 + 1;
			while (x < z) {
				z = x;
				x = (y / x + x) / 2;
			}
		} else if (y != 0) {
			z = 1;
		}
	}
}

// File: contracts/libraries/SafeMath.sol

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

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

// File: contracts/UniswapV2ERC20.sol

contract IERC223NG is IERC20 {
		
	/**
	 * @dev Transfers `value` tokens from `msg.sender` to `to` address with `data` parameter
	 * and returns `true` on success.
	 */
	function transfer(address to, uint value, bytes memory data) public returns (bool);
	function transferFrom(address from, address to, uint value, bytes memory data) public returns (bool);
	 
	 /**
	 * @dev Event that is fired on successful transfer.
	 */
	event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

//Use OpenZeppelin ERC20 Implementation
contract ERC223NG is IERC223NG {
	using SafeMath for uint256;

	mapping (address => uint256) internal _balances;

	mapping (address => mapping (address => uint256)) private _allowed;

	uint256 internal real_totalSupply;

	/**
	* @dev Total number of tokens in existence
	*/
	function totalSupply() external view returns (uint256) {
		return real_totalSupply.sub(_balances[address(0)]);
	}

	/**
	* @dev Gets the balance of the specified address.
	* @param owner The address to query the balance of.
	* @return An uint256 representing the amount owned by the passed address.
	*/
	function balanceOf(address owner) external view returns (uint256) {
		return _balances[owner];
	}

	/**
	 * @dev Function to check the amount of tokens that an owner allowed to a spender.
	 * @param owner address The address which owns the funds.
	 * @param spender address The address which will spend the funds.
	 * @return A uint256 specifying the amount of tokens still available for the spender.
	 */
	function allowance(address owner, address spender) external view returns (uint256) {
		return _allowed[owner][spender];
	}

	/**
	* @dev Transfer token for a specified address
	* @param to The address to transfer to.
	* @param value The amount to be transferred.
	*/
	function transfer(address to, uint256 value) external returns (bool) {
		bytes memory empty = hex"00000000";
		_transfer(msg.sender, to, value, empty);
		return true;
	}
	function transfer(address to, uint256 value, bytes memory data) public returns (bool) {
		_transfer(msg.sender, to, value, data);
		return true;
	}

	/**
	 * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
	 * Beware that changing an allowance with this method brings the risk that someone may use both the old
	 * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
	 * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
	 * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	 * @param spender The address which will spend the funds.
	 * @param value The amount of tokens to be spent.
	 */
	function approve(address spender, uint256 value) external returns (bool) {
		_allowed[msg.sender][spender] = value;
		Approval(msg.sender, spender, value);
		return true;
	}

	/**
	 * @dev Transfer tokens from one address to another.
	 * Note that while this function emits an Approval event, this is not required as per the specification,
	 * and other compliant implementations may not emit the event.
	 * @param from address The address which you want to send tokens from
	 * @param to address The address which you want to transfer to
	 * @param value uint256 the amount of tokens to be transferred
	 */
	function transferFrom(address from, address to, uint256 value) external returns (bool) {
		_allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
		bytes memory empty = hex"00000000";
		_transfer(from, to, value, empty);
		Approval(from, msg.sender, _allowed[from][msg.sender]);
		return true;
	}
	function transferFrom(address from, address to, uint256 value, bytes memory data) public returns (bool) {
		_allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
		_transfer(from, to, value, data);
		Approval(from, msg.sender, _allowed[from][msg.sender]);
		return true;
	}

	/**
	 * @dev Increase the amount of tokens that an owner allowed to a spender.
	 * approve should be called when allowed_[_spender] == 0. To increment
	 * allowed value is better to use this function to avoid 2 calls (and wait until
	 * the first transaction is mined)
	 * From MonolithDAO Token.sol
	 * Emits an Approval event.
	 * @param spender The address which will spend the funds.
	 * @param addedValue The amount of tokens to increase the allowance by.
	 */
	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
		Approval(msg.sender, spender, _allowed[msg.sender][spender]);
		return true;
	}

	/**
	 * @dev Decrease the amount of tokens that an owner allowed to a spender.
	 * approve should be called when allowed_[_spender] == 0. To decrement
	 * allowed value is better to use this function to avoid 2 calls (and wait until
	 * the first transaction is mined)
	 * From MonolithDAO Token.sol
	 * Emits an Approval event.
	 * @param spender The address which will spend the funds.
	 * @param subtractedValue The amount of tokens to decrease the allowance by.
	 */
	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
		Approval(msg.sender, spender, _allowed[msg.sender][spender]);
		return true;
	}
	function isContract(address account) private view returns (bool) {
		// This method relies in extcodesize, which returns 0 for contracts in
		// construction, since the code is only stored at the end of the
		// constructor execution.

		uint256 size;
		// solhint-disable-next-line no-inline-assembly
		assembly { size := extcodesize(account) }
		return size > 0;
	}
	/**
	* @dev Transfer token for a specified addresses
	* @param from The address to transfer from.
	* @param to The address to transfer to.
	* @param value The amount to be transferred.
	*/
	function _transfer(address from, address to, uint256 value, bytes memory data) internal {
		_balances[from] = _balances[from].sub(value);
		_balances[to] = _balances[to].add(value);
		if(isContract(to)) {
			IERC223Recipient receiver = IERC223Recipient(to);
			receiver.tokenFallback(msg.sender, value, data);
		}
		Transfer(from, to, value);
	}

	/**
	 * @dev Internal function that mints an amount of the token and assigns it to
	 * an account. This encapsulates the modification of balances such that the
	 * proper events are emitted.
	 * @param account The account that will receive the created tokens.
	 * @param value The amount that will be created.
	 */
	function _mint(address account, uint256 value) internal {
		real_totalSupply = real_totalSupply.add(value);
		_balances[account] = _balances[account].add(value);
		Transfer(address(0), account, value);
	}

	/**
	 * @dev Internal function that burns an amount of the token of a given
	 * account.
	 * @param account The account whose tokens will be burnt.
	 * @param value The amount that will be burnt.
	 */
	function _burn(address account, uint256 value) internal {
		real_totalSupply = real_totalSupply.sub(value);
		_balances[account] = _balances[account].sub(value);
		Transfer(account, address(0), value);
	}

	/**
	 * @dev Internal function that burns an amount of the token of a given
	 * account, deducting from the sender's allowance for said account. Uses the
	 * internal burn function.
	 * Emits an Approval event (reflecting the reduced allowance).
	 * @param account The account whose tokens will be burnt.
	 * @param value The amount that will be burnt.
	 */
	function _burnFrom(address account, uint256 value) internal {
		_allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
		_burn(account, value);
		Approval(account, msg.sender, _allowed[account][msg.sender]);
	}
}

// File: contracts/interfaces/IUniswapV2Pair.sol

contract IUniswapV2Pair is IERC20 {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external pure returns (string memory);
	function symbol() external pure returns (string memory);
	function decimals() external pure returns (uint8);

	event Mint(address indexed sender, uint amount0, uint amount1);
	event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
	event Swap(
		address indexed sender,
		uint amount0In,
		uint amount1In,
		uint amount0Out,
		uint amount1Out,
		address indexed to
	);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns (uint);
	function factory() external view returns (address);
	function token0() external view returns (address);
	function token1() external view returns (address);
	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
	function price0CumulativeLast() external view returns (uint);
	function price1CumulativeLast() external view returns (uint);
	function kLast() external view returns (uint);

	function mint(address to) external returns (uint liquidity);
	function burn(address to) external returns (uint amount0, uint amount1);
	function swap(uint amount0Out, uint amount1Out, address to, bytes data) external;
	function skim(address to) external;
	function sync() external;

	function initialize(address, address) external;
}

contract IERC223Recipient {
	/**
	 * @dev Standard ERC223 function that will handle incoming token transfers.
	 *
	 * @param _from  Token sender address.
	 * @param _value Amount of tokens.
	 * @param _data  Transaction metadata.
	 */
	function tokenFallback(address _from, uint _value, bytes memory _data) public;
}

contract UniswapV2Pair is ERC223NG, IUniswapV2Pair, IERC223Recipient{
	using SafeMath  for uint;
	using UQ112x112 for uint224;

	function MINIMUM_LIQUIDITY() external pure returns (uint256){
		return 10**3;
	}
	bytes4 private constant SELECTOR = bytes4(keccak256('transfer(address,uint256)'));

	address private _factory;
	function factory() external view returns (address){
		return _factory;
	}
	address private _token0;
	function token0() external view returns (address){
		return _token0;
	}
	address private _token1;
	function token1() external view returns (address){
		return _token1;
	}

	uint112 private _reserve0;		   // uses single storage slot, accessible via getReserves
	uint112 private _reserve1;		   // uses single storage slot, accessible via getReserves
	uint32  private _blockTimestampLast; // uses single storage slot, accessible via getReserves

	uint private _price0CumulativeLast;
	function price0CumulativeLast() external view returns (uint){
		return _price0CumulativeLast;
	}
	uint private _price1CumulativeLast;
	function price1CumulativeLast() external view returns (uint){
		return _price1CumulativeLast;
	}
	uint private _kLast; // _reserve0 * _reserve1, as of immediately after the most recent liquidity event
	function kLast() external view returns (uint){
		return _kLast;
	}

	/**
	 * @return the name of the token.
	 */
	function name() external pure returns (string) {
		return "Uniswap V2 on MintME";
	}

	/**
	 * @return the symbol of the token.
	 */
	function symbol() external pure returns (string) {
		return "UNI-V2";
	}

	/**
	 * @return the number of decimals of the token.
	 */
	function decimals() external pure returns (uint8) {
		return 18;
	}

	uint private unlocked = 1;
	modifier lock() {
		require(unlocked == 1);
		unlocked = 0;
		_;
		unlocked = 1;
	}

	function getReserves() external view returns (uint112 __reserve0, uint112 __reserve1, uint32 __blockTimestampLast) {
		__reserve0 = _reserve0;
		__reserve1 = _reserve1;
		__blockTimestampLast = _blockTimestampLast;
	}
	function getReservesIMPL() private view returns (uint112 __reserve0, uint112 __reserve1, uint32 __blockTimestampLast) {
		__reserve0 = _reserve0;
		__reserve1 = _reserve1;
		__blockTimestampLast = _blockTimestampLast;
	}

	function _safeTransfer(address token, address to, uint value) private {
		require(IERC20(token).transfer(to, value));
	}

	event Mint(address indexed sender, uint amount0, uint amount1);
	event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
	event Swap(
		address indexed sender,
		uint amount0In,
		uint amount1In,
		uint amount0Out,
		uint amount1Out,
		address indexed to
	);

	function UniswapV2Pair(address __token0, address __token1) public {
		_factory = msg.sender;
		_token0 = __token0;
		_token1 = __token1;
	}

	// called once by the _factory at time of deployment
	function initialize(address __token0, address __token1) external {
		revert();
	}

	// update reserves and, on the first call per block, price accumulators
	function _update(uint balance0, uint balance1, uint112 __reserve0, uint112 __reserve1) private {
		require(balance0 <= uint112(-1) && balance1 <= uint112(-1));
		uint32 blockTimestamp = uint32(block.timestamp % 2**32);
		uint32 timeElapsed = blockTimestamp - _blockTimestampLast; // overflow is desired
		if (timeElapsed > 0 && __reserve0 != 0 && __reserve1 != 0) {
			// * never overflows, and + overflow is desired
			_price0CumulativeLast += uint(UQ112x112.encode(__reserve1).uqdiv(__reserve0)) * timeElapsed;
			_price1CumulativeLast += uint(UQ112x112.encode(__reserve0).uqdiv(__reserve1)) * timeElapsed;
		}
		_reserve0 = uint112(balance0);
		_reserve1 = uint112(balance1);
		_blockTimestampLast = blockTimestamp;
		Sync(_reserve0, _reserve1);
	}

	// if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
	function _mintFee(uint112 __reserve0, uint112 __reserve1) private returns (bool feeOn) {
		address feeTo = IUniswapV2Factory(_factory).feeTo();
		feeOn = feeTo != address(0);
		uint __kLast = _kLast; // gas savings
		if (feeOn) {
			if (__kLast != 0) {
				uint rootK = Math.sqrt(uint(__reserve0).mul(__reserve1));
				uint rootKLast = Math.sqrt(__kLast);
				if (rootK > rootKLast) {
					uint numerator = real_totalSupply.mul(rootK.sub(rootKLast));
					uint denominator = rootK.mul(5).add(rootKLast);
					uint liquidity = numerator / denominator;
					if (liquidity > 0) _mint(feeTo, liquidity);
				}
			}
		} else if (__kLast != 0) {
			_kLast = 0;
		}
	}

	// this low-level function should be called from a contract which performs important safety checks
	function mint(address to) external lock returns (uint liquidity) {
		uint112 __reserve0;
		uint112 __reserve1;
		(__reserve0, __reserve1,) = getReservesIMPL(); // gas savings
		uint balance0 = IERC20(_token0).balanceOf(address(this));
		uint balance1 = IERC20(_token1).balanceOf(address(this));
		uint amount0 = balance0.sub(__reserve0);
		uint amount1 = balance1.sub(__reserve1);

		bool feeOn = _mintFee(__reserve0, __reserve1);
		uint _totalSupply = real_totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
		if (_totalSupply == 0) {
			liquidity = Math.sqrt(amount0.mul(amount1)).sub(10**3);
		   _mint(address(0), 10**3); // permanently lock the first MINIMUM_LIQUIDITY tokens
		} else {
			liquidity = Math.min(amount0.mul(_totalSupply) / __reserve0, amount1.mul(_totalSupply) / __reserve1);
		}
		require(liquidity > 0);
		_mint(to, liquidity);

		_update(balance0, balance1, __reserve0, __reserve1);
		if (feeOn) _kLast = uint(_reserve0).mul(_reserve1); // _reserve0 and _reserve1 are up-to-date
		Mint(msg.sender, amount0, amount1);
	}

	// this low-level function should be called from a contract which performs important safety checks
	function burn(address to) external lock returns (uint amount0, uint amount1) {
		uint112 __reserve0;
		uint112 __reserve1;
		(__reserve0, __reserve1,) = getReservesIMPL(); // gas savings
		address __token0 = _token0;								// gas savings
		address __token1 = _token1;								// gas savings
		uint balance0 = IERC20(__token0).balanceOf(address(this));
		uint balance1 = IERC20(__token1).balanceOf(address(this));
		uint liquidity = _balances[address(this)];

		bool feeOn = _mintFee(__reserve0, __reserve1);
		uint _totalSupply = real_totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
		amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
		amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
		require(amount0 > 0 && amount1 > 0);
		_burn(address(this), liquidity);
		_safeTransfer(__token0, to, amount0);
		_safeTransfer(__token1, to, amount1);
		balance0 = IERC20(__token0).balanceOf(address(this));
		balance1 = IERC20(__token1).balanceOf(address(this));

		_update(balance0, balance1, __reserve0, __reserve1);
		if (feeOn) _kLast = uint(_reserve0).mul(_reserve1); // _reserve0 and _reserve1 are up-to-date
		Burn(msg.sender, amount0, amount1, to);
	}
	function _preswap1(uint256 out0, uint256 out1, address to, bytes data) private returns (uint256, uint256){
		address __token0 = _token0;
		address __token1 = _token1;
		require(to != __token0 && to != __token1);
		if (out0 > 0) _safeTransfer(__token0, to, out0); // optimistically transfer tokens
		if (out1 > 0) _safeTransfer(__token1, to, out1); // optimistically transfer tokens
		if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, out0, out1, data);
		return (IERC20(__token0).balanceOf(address(this)), IERC20(__token1).balanceOf(address(this)));
	}
	// this low-level function should be called from a contract which performs important safety checks
	function swap(uint amount0Out, uint amount1Out, address to, bytes data) external lock {
		require(amount0Out > 0 || amount1Out > 0);
		uint112 __reserve0;
		uint112 __reserve1;
		(__reserve0, __reserve1,) = getReservesIMPL(); // gas savings
		require(amount0Out < __reserve0 && amount1Out < __reserve1);

		uint balance0;
		uint balance1;
		{
			(balance0, balance1) = _preswap1(amount0Out, amount1Out, to, data);
			uint amount0In = balance0 > __reserve0 - amount0Out ? balance0 - (__reserve0 - amount0Out) : 0;
			uint amount1In = balance1 > __reserve1 - amount1Out ? balance1 - (__reserve1 - amount1Out) : 0;
			require(amount0In > 0 || amount1In > 0);
			uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
			uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
			require(balance0Adjusted.mul(balance1Adjusted) >= uint(__reserve0).mul(__reserve1).mul(1000**2));
		}

		_update(balance0, balance1, __reserve0, __reserve1);
		emitSwap(amount0In, amount1In, amount0Out, amount1Out, to);
	}
	function emitSwap(uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address to) private{
		Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
	}

	// force balances to match reserves
	function skim(address to) external lock {
		address __token0 = _token0; // gas savings
		address __token1 = _token1; // gas savings
		_safeTransfer(__token0, to, IERC20(__token0).balanceOf(address(this)).sub(_reserve0));
		_safeTransfer(__token1, to, IERC20(__token1).balanceOf(address(this)).sub(_reserve1));
	}

	// force reserves to match balances
	function sync() external lock {
		_update(IERC20(_token0).balanceOf(address(this)), IERC20(_token1).balanceOf(address(this)), _reserve0, _reserve1);
	}
	// wrong token protection - protects against sending the wrong token to Uniswap V2
	function tokenFallback(address from, uint256 value, bytes memory data) public{
		require(msg.sender == _token0 || msg.sender == _token1 || msg.sender == address(this));
	}
}

// File: contracts/interfaces/IUniswapV2Factory.sol

interface IUniswapV2Factory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);

	function feeTo() external view returns (address);
	function feeToSetter() external view returns (address);

	function getPair(address tokenA, address tokenB) external view returns (address pair);
	function allPairs(uint) external view returns (address pair);
	function allPairsLength() external view returns (uint);

	function createPair(address tokenA, address tokenB) external returns (address pair);

	function setFeeTo(address) external;
	function setFeeToSetter(address) external;
}

// File: contracts/UniswapV2Factory.sol

contract TokenDetails{
	function decimals() public view returns (uint256);
	function name() public view returns (string);
	function symbol() public view returns (string);
}
contract ERC223IMPL is ERC223NG {
	string private _name;
	string private _symbol;
	address private _uniswap;

	function ERC223IMPL (string name, string symbol, address minter) public {
		_name = name;
		_symbol = symbol;
		real_totalSupply = 10000000 szabo;
		_balances[minter] = 10000000 szabo;
	}

	/**
	 * @return the name of the token.
	 */
	function name() external view returns (string) {
		return _name;
	}

	/**
	 * @return the symbol of the token.
	 */
	function symbol() external view returns (string) {
		return _symbol;
	}

	/**
	 * @return the number of decimals of the token.
	 */
	function decimals() external pure returns (uint8) {
		return 12;
	}
}
contract IERC223TokenFactory{
	function createToken(string name, string symbol) external returns (address);
	function getTokenFromName(string name) external view returns (address);
	function getTokenFromSymbol(string symbol) external view returns (address);
	function launchedUsingThis(address token) external view returns (bool);
}

contract CentralFactory is IUniswapV2Factory, IERC223TokenFactory {
	address private _centralToken;
	address private _jessie;
	function centralToken() external view returns (address){
		return _centralToken;
	}
	function CentralFactory() public{
		address token = address(new ERC223IMPL("MintyDEFI Central Token", "MDFI", msg.sender));
		_createdTokensByName["MintyDEFI"] = token;
		_createdTokensBySymbol["MDFI"] = token;
		_centralToken = token;
		_launchedUsingThis[token] = true;
		_jessie = msg.sender;
	}
	function feeTo() external view returns (address){
		return _jessie;
	}
	function feeToSetter() external view returns (address){
		return _jessie;
	}

	mapping(address => mapping(address => address)) private _getPair;
	function getPair(address a, address b) external view returns (address){
		return _getPair[a][b];
	}
	address[] private _allPairs;
	function allPairs(uint256 a) external view returns (address){
		return _allPairs[a];
	}

	event PairCreated(address indexed token0, address indexed token1, address pair, uint);

	function allPairsLength() external view returns (uint) {
		return _allPairs.length;
	}
	
	mapping(address => bool) private _launchedUsingThis;
	
	function _createPair(address tokenA, address tokenB) private returns (address pair) {
		require(tokenA != tokenB);
		(tokenA, tokenB) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
		require(tokenA != address(0));
		require(_getPair[tokenA][tokenB] == address(0)); // single check is sufficient
		pair = new UniswapV2Pair(tokenA, tokenB);
		_getPair[tokenA][tokenB] = pair;
		_getPair[tokenB][tokenA] = pair; // populate mapping in the reverse direction
		_allPairs.push(pair);
		PairCreated(tokenA, tokenB, pair, _allPairs.length);
	}
	function launchedUsingThis(address token) external view returns (bool){
		return _launchedUsingThis[token];
	}

	function createPair(address tokenA, address tokenB) external returns (address) {
		return _createPair(tokenA, tokenB);
	}
	function setFeeTo(address addr) external{
		revert();
	}
	function setFeeToSetter(address addr) external{
		revert();
	}
	
	//MintyDEFI stuff again
	mapping(string => address) private _createdTokensByName;
	mapping(string => address) private _createdTokensBySymbol;
	function createToken(string name, string symbol) external returns (address token){
		require(_createdTokensByName[name] == address(0));
		require(_createdTokensBySymbol[symbol] == address(0));
		require(bytes(symbol).length < 6);
		token = address(new ERC223IMPL(name, symbol, msg.sender));
		_createPair(_centralToken, token);
		_createdTokensByName[name] = token;
		_createdTokensBySymbol[symbol] = token;
		_launchedUsingThis[token] = true;
	}
	function getTokenFromName(string name) external view returns (address){
		return _createdTokensByName[name];
	}
	function getTokenFromSymbol(string symbol) external view returns (address){
		return _createdTokensBySymbol[symbol];
	}
}
