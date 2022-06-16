// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import 'hardhat/console.sol';
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import '../lib/Utils.sol';


interface IGatekeeper {
    function hasRole(bytes32 role, address account) external view returns (bool);
}

/// @custom:oz-upgrades-unsafe-allow external-library-linking
contract PunchOut is Initializable, ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable {
    using UtilsUint for uint;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    //    struct Match {}

    //    struct Bet {}

    string public constant name = 'Punchout';
    string public constant symbol = 'PUNCH';
    bytes32 internal constant OWNER = keccak256("ARENA_OWNER");
    bytes32 internal constant ADMIN = keccak256("ARENA_ADMIN");
    bytes32 internal constant STAFF = keccak256("ARENA_STAFF");

    mapping(uint => string) public gateways;
    CountersUpgradeable.Counter internal gatewayCounter;
    IGatekeeper public gk;


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC1155_init("");
        __Ownable_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
    }

    modifier onlyRole(bytes32 role) {
        require(gk.hasRole(role, _msgSender()), 'You shall not pass!');
        _;
    }

    function addGateway(string memory _uri) public virtual onlyRole(ADMIN) {
        _addGateway(_uri);
    }

    function _addGateway(string memory _uri) internal virtual {
        require(bytes(_uri).length != 0, 'GATEWAY: Does not exist');
        uint gatewayId = gatewayCounter.current();
        gateways[gatewayId] = _uri;
        gatewayCounter.increment();
    }

    function setGatekeeper(address addr) external virtual onlyRole(ADMIN) {
        _setGatekeeper(addr);
    }

    function _setGatekeeper(address addr) internal virtual {
        require(addr != address(0), 'OOPS: Address cannot be empty');
        gk = IGatekeeper(addr);
    }




    //    function setURI(string memory newuri) public onlyOwner {
    //        _setURI(newuri);
    //    }
    //
    //    function pause() public onlyOwner {
    //        _pause();
    //    }
    //
    //    function unpause() public onlyOwner {
    //        _unpause();
    //    }
    //
    //    function mint(address account, uint256 id, uint256 amount, bytes memory data)
    //    public
    //    onlyOwner
    //    {
    //        _mint(account, id, amount, data);
    //    }
    //
    //    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    //    public
    //    onlyOwner
    //    {
    //        _mintBatch(to, ids, amounts, data);
    //    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    internal whenNotPaused override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _authorizeUpgrade(address newImplementation) internal onlyRole(OWNER) override {}

}