// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DragonNFT is Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 private _nextDragonId = 1;

    string private firestonePrefix = "";
    string private firestoneSuffix = ".json";
    string private dragonMetadataURI;

    uint256 public tribute;
    uint256 public dragonNestLimit;
    uint256 public maxEggsPerHoard = 2;
    uint256 public maxEggsPerHatch = 2;

    mapping(address => uint256) public hoardMints;

    modifier hatchCompliance(uint256 quantity) {
        require(
            quantity > 0 && quantity <= maxEggsPerHatch,
            "Invalid hatch amount!"
        );
        require(
            totalSupply() + quantity <= dragonNestLimit,
            "Nest limit exceeded!"
        );
        require(
            hoardMints[msg.sender] + quantity <= maxEggsPerHoard,
            "Hoard mint limit exceeded!"
        );
        hoardMints[msg.sender] += quantity;
        _;
    }

    constructor(
        uint256 _tribute,
        uint256 _dragonNestLimit,
        string memory _dragonMetadataURI
    ) {
        dragonNestLimit = _dragonNestLimit;
        setTribute(_tribute);
        setDragonMetadataURI(_dragonMetadataURI);
    }

    function safeHatch(address to) external onlyOwner {
        uint256 dragonId = _nextDragonId++;
        _safeMint(to, dragonId);
        _setDragonURI(dragonId, "");
    }

    function hatch(
        uint256 quantity
    ) external payable hatchCompliance(quantity) {
        uint256 _totalTribute = tribute * quantity;
        require(
            msg.value >= _totalTribute,
            "Value cannot be lower than total tribute"
        );

        uint256 dragonId;
        for (uint256 i = 0; i < quantity; i++) {
            dragonId = _nextDragonId++;
            _safeMint(msg.sender, dragonId);
            _setDragonURI(dragonId, "");
        }
    }

    function withdraw() public onlyOwner nonReentrant {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }

    function allDragonsOfOwner(
        address owner_
    ) public view returns (uint256[] memory) {
        uint256 balance = balanceOf(owner_);
        uint256[] memory dragons = new uint256[](balance);

        for (uint256 i = 0; i < balance; i++) {
            dragons[i] = dragonOfOwnerByIndex(owner_, i);
        }

        return dragons;
    }

    function setTribute(uint256 _tribute) public onlyOwner {
        tribute = _tribute;
    }

    function setMaxEggsPerHoard(uint256 _maxEggsPerHoard) public onlyOwner {
        maxEggsPerHoard = _maxEggsPerHoard;
    }

    function reduceDragonNestLimit(uint256 _dragonNestLimit) public onlyOwner {
        require((dragonNestLimit - _dragonNestLimit) > 0, "No action needed");
        dragonNestLimit = _dragonNestLimit;
    }

    function setDragonMetadataURI(
        string memory _dragonMetadataURI
    ) public onlyOwner {
        dragonMetadataURI = _dragonMetadataURI;
    }

    function _baseURI() internal view returns (string memory) {
        return dragonMetadataURI;
    }

    function dragonURI(uint256 dragonId) public view returns (string memory) {
        require(
            _exists(dragonId),
            "ERC721 Metadata: URI query for nonexistent dragon"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        dragonId.toString(),
                        firestoneSuffix
                    )
                )
                : "";
    }

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _exists(uint256 dragonId) private view returns (bool) {
        try this.ownerOf(dragonId) returns (address) {
            return true;
        } catch {
            return false;
        }
    }
}
