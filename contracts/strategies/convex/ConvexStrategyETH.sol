// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {ConvexBaseStrategy} from "./ConvexBaseStrategy.sol";
import {ICurveDeposit_2token} from "../../interfaces/curve/ICurveDeposit_2token.sol";
import {IERC20Detailed} from "../../interfaces/IERC20Detailed.sol";
import {IWETH9} from "../../interfaces/IWETH9.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

contract ConvexStrategyETH is ConvexBaseStrategy {
    using SafeERC20Upgradeable for IERC20Detailed;

    /// @notice curve N_COINS for the pool
    uint256 public constant CURVE_UNDERLYINGS_SIZE = 2;

    /// @return size of the curve deposit array
    function _curveUnderlyingsSize() internal pure override returns(uint256) {
        return CURVE_UNDERLYINGS_SIZE;
    }

    /// @notice Deposits in Curve for pools with 2 ETH-based tokens
    /// @dev This should be used to implement the strategy with curve pool such as reth, steth, seth
    function _depositInCurve(uint256 _minLpTokens) internal override {
        IWETH9 _weth = IWETH9(WETH);
        uint256 _balance = _weth.balanceOf(address(this));
        
        _weth.withdraw(_balance);

        // we can accept 0 as minimum, this will be called only by trusted roles
        uint256[2] memory _depositArray;
        _depositArray[depositPosition] = _balance;
        ICurveDeposit_2token(_curvePool()).add_liquidity{value: _balance}(_depositArray, _minLpTokens);
    }

    receive() external payable {}
}