pragma solidity =0.4.17;
interface IUniswapV2Pair {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external pure returns (string memory);
	function symbol() external pure returns (string memory);
	function decimals() external pure returns (uint8);
	function totalSupply() external view returns (uint);
	function balanceOf(address owner) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);
	function transfer(address to, uint value) external returns (bool);
	function transferFrom(address from, address to, uint value) external returns (bool);

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
interface IERC20 {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
	function totalSupply() external view returns (uint);
	function balanceOf(address owner) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);
	function transfer(address to, uint value) external returns (bool);
	function transferFrom(address from, address to, uint value) external returns (bool);
}
library Math {
	/**
	* @dev Returns the largest of two numbers.
	*/
	function max(uint256 a, uint256 b) internal pure returns (uint256) {
		return a >= b ? a : b;
	}

	/**
	* @dev Returns the smallest of two numbers.
	*/
	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}

	/**
	* @dev Calculates the average of two numbers. Since these are integers,
	* averages of an even and odd number cannot be represented, and will be
	* rounded down.
	*/
	function average(uint256 a, uint256 b) internal pure returns (uint256) {
		// (a + b) / 2 can overflow, so we distribute
		return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
	}
}
library SafeMath {
	/**
	* @dev Multiplies two numbers, reverts on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b);

		return c;
	}

	/**
	* @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	* @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;

		return c;
	}

	/**
	* @dev Adds two numbers, reverts on overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);

		return c;
	}

	/**
	* @dev Divides two numbers and returns the remainder (unsigned integer modulo),
	* reverts when dividing by zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0);
		return a % b;
	}
}
contract MintMEUniswapLiquidityManager{
	using SafeMath for uint;
	using Math for uint;
	address public constant uniswapFactory = 0x77d062eb1dd9fb48a9875c73abf6c6d247e91b39;
	// returns sorted token addresses, used to handle return values from pairs sorted in this order
	function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
		require(tokenA != tokenB);
		(token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
		require(token0 != address(0));
	}
	// fetches and sorts the reserves for a pair
	function getReserves(address tokenA, address tokenB) public view returns (uint reserveA, uint reserveB) {
		address token0;
		(token0,) = sortTokens(tokenA, tokenB);
		address temp = IUniswapV2Factory(uniswapFactory).getPair(tokenA, tokenB);
		require(temp != address(0));
		(reserveA, reserveB,) = IUniswapV2Pair(temp).getReserves();
		(reserveA, reserveB) = tokenA == token0 ? (reserveA, reserveB) : (reserveB, reserveA);
	}
	
	// given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
	function quote(uint amountA, uint reserveA, uint reserveB) public pure returns (uint amountB) {
		require(amountA > 0);
		require(reserveA > 0 && reserveB > 0);
		amountB = amountA.mul(reserveB) / reserveA;
	}
	function _preswap(address token0, address token1) private returns (IUniswapV2Pair){
		IUniswapV2Factory factory = IUniswapV2Factory(uniswapFactory);
		IUniswapV2Pair pair;
		{
			address pairaddr = factory.getPair(token0, token1);
			if(pairaddr == address(0)){
				pair = IUniswapV2Pair(factory.createPair(token0, token1));
			} else{
				pair = IUniswapV2Pair(pairaddr);
			}
		}
		return pair;
	}
	function addLiquidity(
		address tokenA,
		address tokenB,
		uint amountADesired,
		uint amountBDesired
	) external returns (uint amountA, uint amountB) {
		address uniswap = _preswap(tokenA, tokenB);
		uint reserveA;
		uint reserveB;
		(reserveA, reserveB) = getReserves(tokenA, tokenB);
		if (reserveA == 0 && reserveB == 0) {
			(amountA, amountB) = (amountADesired, amountBDesired);
		} else {
			uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
			if (amountBOptimal <= amountBDesired) {
				(amountA, amountB) = (amountADesired, amountBOptimal);
			} else {
				uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
				require(amountAOptimal <= amountADesired);
				(amountA, amountB) = (amountAOptimal, amountBDesired);
			}
		}
		safeTransferFrom2(tokenA, uniswap, amountA);
		safeTransferFrom2(tokenB, uniswap, amountB);
		IUniswapV2Pair(uniswap).mint(msg.sender);
	}
	function safeTransferFrom2(address token, address to, uint amount) public{
		IERC20 erc20 = IERC20(token);
		require(erc20.transferFrom(msg.sender, to, amount));
	}
	function tokenFallback(address _from, uint _value, bytes memory _data) public{
		require(IERC20(msg.sender).transfer(msg.sender, _value));
		IUniswapV2Pair(msg.sender).burn(_from);
	}

}
