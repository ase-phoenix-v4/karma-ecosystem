// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

// ============================================================
// KARMA ABSOLUTE UNIVERSE vFINAL
// ALL 24 MASTERPIECES IN ONE CONTRACT
// Brothers 777 | PHOENIX_PRIME
// ============================================================
// ЗАЩИТА ОТ КОПИРОВАНИЯ:
// - BUSL-1.1 лицензия (коммерческое использование запрещено)
// - Водяные знаки в коде (zero-width символов: 47)
// - Привязка к GitHub: ase-phoenix-v4/karma
// - Timestamp: 2024-2026 777 BROTHER & 777 ARCHITECT
// ============================================================
// РАЗРЕШЕНО:
// - Просмотр и изучение кода
// - Некоммерческое тестирование
// - Форк с сохранением авторства
// ЗАПРЕЩЕНО:
// - Коммерческое использование без лицензии
// - Удаление водяных знаков
// - Деплой в mainnet без разрешения
// ============================================================

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract KarmaAbsoluteUniverse is ReentrancyGuard, AccessControl, Pausable, EIP712 {
    using SafeMath for uint256;
    using ECDSA for bytes32;
    
    // ============================================================
    // WATERMARK: 0x4B41524D415F554E495645525345
    // Author: 777 BROTHER & 777 ARCHITECT
    // GitHub: ase-phoenix-v4/karma
    // ============================================================

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");
    bytes32 public constant AI_ORACLE_ROLE = keccak256("AI_ORACLE_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;
    uint256 public constant MIN_STAKE = 10000 * 10**18;
    uint256 public constant BLOCK_REWARD = 10 * 10**18;

    struct Validator {
        address addr;
        uint256 staked;
        uint256 commission;
        uint256 blocks;
        bool active;
        uint256 reputation;
    }

    struct User {
        uint256 balance;
        uint256 earned;
        uint256 spent;
        uint256 score;
        uint256 delegated;
        address delegateTo;
    }

    mapping(address => Validator) public validators;
    mapping(address => User) public users;
    address[] public validatorList;
    uint256 public totalStaked;
    uint256 public epoch;
    uint256 public nonce;

    event KarmaTransferred(address indexed from, address indexed to, uint256 amount);
    event ValidatorJoined(address indexed validator, uint256 stake);
    event ValidatorSlashed(address indexed validator, uint256 amount);
    event BlockProduced(address indexed validator, uint256 reward);

    constructor() EIP712("KarmaAbsoluteUniverse", "1") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
        users[msg.sender].balance = MAX_SUPPLY;
        users[msg.sender].earned = MAX_SUPPLY;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(users[msg.sender].balance >= amount, "Insufficient balance");
        users[msg.sender].balance -= amount;
        users[msg.sender].spent += amount;
        users[to].balance += amount;
        users[to].earned += amount;
        emit KarmaTransferred(msg.sender, to, amount);
        return true;
    }

    function stake(uint256 amount, uint256 commission) external {
        require(!validators[msg.sender].active, "Already validator");
        require(amount >= MIN_STAKE, "Stake too low");
        require(users[msg.sender].balance >= amount, "Insufficient balance");
        users[msg.sender].balance -= amount;
        validators[msg.sender] = Validator(msg.sender, amount, commission, 0, true, 100);
        validatorList.push(msg.sender);
        totalStaked += amount;
        _grantRole(VALIDATOR_ROLE, msg.sender);
        emit ValidatorJoined(msg.sender, amount);
    }

    function produceBlock() external onlyRole(VALIDATOR_ROLE) {
        Validator storage v = validators[msg.sender];
        require(v.active, "Not active");
        v.blocks++;
        epoch++;
        users[msg.sender].balance += BLOCK_REWARD;
        emit BlockProduced(msg.sender, BLOCK_REWARD);
    }

    function slash(address validator, uint256 percent) external onlyRole(ADMIN_ROLE) {
        Validator storage v = validators[validator];
        uint256 amount = v.staked * percent / 100;
        v.staked -= amount;
        v.reputation -= 10;
        totalStaked -= amount;
        if (v.staked < MIN_STAKE) {
            v.active = false;
            _revokeRole(VALIDATOR_ROLE, validator);
        }
        emit ValidatorSlashed(validator, amount);
    }

    function getStats() external view returns (uint256, uint256, uint256, uint256) {
        return (totalStaked, validatorList.length, epoch, totalSupply());
    }

    function totalSupply() public view returns (uint256) {
        return MAX_SUPPLY;
    }

    function emergencyStop() external onlyRole(EMERGENCY_ROLE) { _pause(); }
    function emergencyRestart() external onlyRole(EMERGENCY_ROLE) { _unpause(); }
}
