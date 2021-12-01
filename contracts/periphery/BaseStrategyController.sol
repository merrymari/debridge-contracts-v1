// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IStrategy.sol";

abstract contract BaseStrategyController is IStrategy {

    uint256 public constant denominator = 10e18;
    address public delegatedStaking;

    event StrategyReset(address _strategy, address collateral);
    error StrategyDisabled();
    error AlreadyExists();
    error MethodNotImplemented();
    error WrongAmount();
    error AccessDenied();

    /* ========== MODIFIERS ========== */

    modifier onlyDelegatedStaking() {
        if (msg.sender != delegatedStaking) revert AccessDenied();
        _;
    }

    struct Validator {
        uint256 sShares;
        uint256 totalReserves;
        mapping(address => Delegator) delegators;
    }

    struct Delegator {
        uint256 sShares;
        uint256 lockedShares;
        uint256 lockedReserves;
    }

    struct Strategy {
        address strategyToken;
        address rewardToken;
        uint256 totalShares;
        uint256 totalReserves;
        mapping(address => Validator) validators;
        bool isEnabled;
        bool exists;
        bool isRecoverable;
    }

    event EmergencyWithdrawnFromStrategy(uint256 amount, address strategy, address collateral);

    mapping(address => Strategy) public strategies; // collateral => Strategy

    constructor(address _delegatedStaking) {
        delegatedStaking = _delegatedStaking;
    }

    function _strategyToken(address _collateral) internal view virtual returns (address) {
        return strategies[_collateral].strategyToken;
    }

    function _calculateShares(address _collateral, uint256 _amount) internal view returns (uint256) {
        uint256 totalReserves = _totalReserves(_collateral);
        if (totalReserves > 0) {
            return (_amount * strategies[_collateral].totalShares) / totalReserves;
        } else {
            return _amount;
        }
    }

    function _calculateFromShares(address _collateral, uint256 _shares) internal view returns (uint256) {
        Strategy storage strategy = strategies[_collateral];
        if (strategy.totalShares == 0) {
            return 0;
        }
        return (_shares * strategy.totalReserves) / strategy.totalShares;
    }

    function delegatorShares(
        address _collateral,
        address _validator,
        address _delegator
    ) external view override returns (uint256) {
        return _delegatorShares(_collateral, _validator, _delegator);
    }

    function _delegatorShares(
        address _collateral,
        address _validator,
        address _delegator
    ) internal view returns (uint256) {
        return strategies[_collateral].validators[_validator].delegators[_delegator].sShares;
    }

    function validatorShares(address _collateral, address _validator)
        external
        view
        override
        returns (uint256)
    {
        return _validatorShares(_collateral, _validator);
    }

    function _validatorShares(address _collateral, address _validator)
        internal
        view
        returns (uint256)
    {
        return strategies[_collateral].validators[_validator].sShares;
    }

    function totalShares(address _collateral) external view override returns (uint256) {
        return strategies[_collateral].totalShares;
    }

    function totalReserves(address _collateral) external view override returns (uint256) {
        return _totalReserves(_collateral);
    }

    function _totalReserves(address _collateral) internal view returns (uint256) {
        return IERC20(_collateral).balanceOf(address(this)) + 
    }

    function isEnabled(address _collateral) external view override returns (bool) {
        return strategies[_collateral].isEnabled;
    }

    function strategyInfo(address _collateral) external view override returns (bool, bool) {
        return (strategies[_collateral].isEnabled, strategies[_collateral].isRecoverable);
    }

    // TODO: Need to add Access Control to all functions below

    function updateStrategyEnabled(address _collateral, bool _isEnabled) external override onlyDelegatedStaking {
        strategies[_collateral].isEnabled = _isEnabled;
    }

    function updateStrategyRecoverable(address _collateral, bool _isRecoverable) external override onlyDelegatedStaking {
        strategies[_collateral].isRecoverable = _isRecoverable;
    }

    // TODO: fix tests which using this
    function resetStrategy(address _collateral) external override onlyDelegatedStaking {
        Strategy storage strategy = strategies[_collateral];
        if (!strategy.isEnabled) revert StrategyDisabled();
        strategy.totalReserves = 0;
        strategy.totalShares = 0;
        strategy.isEnabled = true;
        strategy.isRecoverable = false;
        emit StrategyReset(address(this), _collateral);
    }

    function addStrategy(address _collateral, address _rewardToken) external override onlyDelegatedStaking {
        Strategy storage strategy = strategies[_collateral];
        if (strategy.exists) revert AlreadyExists();
        strategy.strategyToken = _strategyToken(_collateral);
        strategy.rewardToken = _rewardToken;
        strategy.isEnabled = true;
        strategy.exists = true;
    }

    function slashValidatorDeposits(
        address _validator,
        address _collateral,
        uint256 _slashingFraction
    ) external override onlyDelegatedStaking returns(uint256) {
        uint256 _shares = _validatorShares(_collateral, _validator) * _slashingFraction;
        strategies[_collateral].validators[_validator].sShares -= _shares;
        // TODO
        //uint256 collateralAmount = calculateFromShares(_collateral, _shares);
        //withdraw(_collateral, _validator, collateralAmount, msg.sender);
        return _shares;
    }

    function slashDelegatorDeposits(
        address _validator,
        address _delegator,
        address _collateral,
        uint256 _slashingFraction
    ) external override onlyDelegatedStaking returns(uint256) {
        uint256 _shares = _delegatorShares(_collateral, _validator, _delegator) * _slashingFraction;
        strategies[_collateral].validators[_validator].delegators[_delegator].sShares -= _shares;
        strategies[_collateral].validators[_validator].sShares -= _shares;
        // TODO
        //uint256 collateralAmount = calculateFromShares(_collateral, _shares);
        //withdraw(_collateral, _validator, collateralAmount, msg.sender);
        return _shares;
    }

    // TODO: withdraw function

    function _deposit(address _collateral, uint256 _amount) internal virtual {
        revert MethodNotImplemented(); // assumed to be overriden in imlementation contracts
    }

    function _withdrawFromUnderlyingProtocol(address _collateral, uint256 _amount) internal virtual {
        revert MethodNotImplemented(); // assumed to be overriden in imlementation contracts
    }

    function deposit(address _collateral, address _validator, address _recipient, uint256 _shares, uint256 _amount) external override onlyDelegatedStaking {
        _deposit(_collateral, _amount);
        uint256 _sShares = _calculateShares(_collateral, _amount);
        Strategy storage strategy = strategies[_collateral];
        Delegator storage delegator = validators[_validator].delegators[_recipient];
        delegator.sShares += _sShares;
        delegator.lockedShares += _shares;
        delegator.lockedReserves += _amount;

        strategy.validators[_validator].sShares += _sShares;
        strategy.validators[_validator].totalReserves += _amount;
        strategy.totalShares += _sShares;
        strategy.totalReserves += _amount;
    }

    function withdraw(address _collateral, address _validator, address _recipient, uint256 _shares) external override returns(bool, uint256) onlyDelegatedStaking {
        Strategy storage strategy = strategies[_collateral];
        Delegator storage delegator = validators[_validator].delegators[_recipient];
        if (shares > delegator.lockedShares) revert WrongAmount();       

        uint256 percentageToWithdraw = _shares * denominator / delegator.lockedShares;
        uint256 _sShares = (percentageToWithdraw * delegator.sShares) / denominator;
        
        uint256 amountToBePaid = _calculateFromShares(_collateral, _sShares);
        _ensureBalancesWithdrawal(_collateral, amountToBePaid);
        IERC20(_collateral).safeTranfer(delegatedStaking, amountToBePaid);
        uint256 amountToBeUnlocked = (percentageToWithdraw * delegator.lockedReserves) / denominator;

        delegator.sShares -= _sShares;
        delegator.lockedShares -= _shares;
        delegator.lockedReserves -= amountToBeUnlocked;

        strategy.validators[_validator].sShares -= _sShares;
        strategy.validators[_validator].totalReserves -= amountToBePaid;
        strategy.totalShares -= _sShares;
        strategy.totalReserves -= amountToBePaid;

        if (amountToBePaid > amountToBeUnlocked) {
            // strategy profits
            return true, amountToBePaid - amountToBeUnlocked;
        } else {
            // strategy losses
            return false, amountToBeUnlocked - amountToBePaid;
        }
    }

    // TODO: 
    // withdrawAll functio to update state
    // revert if strategy is disabled
    // strategyController.updateStrategyEnabled(_stakeToken, false);
    // strategyController.updateStrategyRecoverable(_stakeToken, true);
    // emit EmergencyWithdrawnFromStrategy
}
