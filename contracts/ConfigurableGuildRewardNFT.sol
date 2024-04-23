//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IConfigurableGuildRewardNFT } from "./interfaces/IConfigurableGuildRewardNFT.sol";
import { IGuildRewardNFTFactory } from "./interfaces/IGuildRewardNFTFactory.sol";
import { ITreasuryManager } from "./interfaces/ITreasuryManager.sol";
import { LibTransfer } from "./lib/LibTransfer.sol";
import { OptionallySoulboundERC721 } from "./token/OptionallySoulboundERC721.sol";
import { TreasuryManager } from "./utils/TreasuryManager.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title An NFT distributed as a reward for Guild.xyz users.
contract ConfigurableGuildRewardNFT is
    IConfigurableGuildRewardNFT,
    Initializable,
    OwnableUpgradeable,
    OptionallySoulboundERC721,
    TreasuryManager
{
    using ECDSA for bytes32;
    using LibTransfer for address payable;

    address public factoryProxy;
    uint256 public mintableAmountPerUser;

    /// @notice The cid for tokenURI.
    string internal cid;

    /// @notice The number of claimed tokens by userIds.
    mapping(uint256 userId => uint256 claimed) internal claimedTokens;

    function initialize(
        IGuildRewardNFTFactory.ConfigurableNFTConfig memory nftConfig,
        address factoryProxyAddress
    ) public initializer {
        cid = nftConfig.cid;
        mintableAmountPerUser = nftConfig.mintableAmountPerUser;
        factoryProxy = factoryProxyAddress;

        __OptionallySoulboundERC721_init(nftConfig.name, nftConfig.symbol, nftConfig.soulbound);
        __TreasuryManager_init(nftConfig.treasury, nftConfig.tokenFee);

        _transferOwnership(nftConfig.tokenOwner);
    }

    function claim(uint256 amount, address receiver, uint256 userId, bytes calldata signature) external payable {
        if (
            amount > mintableAmountPerUser - balanceOf(receiver) ||
            amount > mintableAmountPerUser - claimedTokens[userId]
        ) revert AlreadyClaimed();
        if (!isValidSignature(amount, receiver, userId, signature)) revert IncorrectSignature();

        (uint256 guildFee, address payable guildTreasury) = ITreasuryManager(factoryProxy).getFeeData();

        claimedTokens[userId] += amount;

        uint256 firstTokenId = totalSupply();
        uint256 lastTokenId = firstTokenId + amount - 1;

        for (uint256 tokenId = firstTokenId; tokenId <= lastTokenId; ++tokenId) {
            _safeMint(receiver, tokenId);

            if (soulbound) emit Locked(tokenId);

            emit Claimed(receiver, tokenId);
        }

        // Fee collection
        if (msg.value == amount * (guildFee + fee)) {
            guildTreasury.sendEther(amount * guildFee);
            treasury.sendEther(amount * fee);
        } else revert IncorrectFee(msg.value, amount * (guildFee + fee));
    }

    function burn(uint256[] calldata tokenIds, uint256 userId, bytes calldata signature) external {
        uint256 amount = tokenIds.length;
        if (!isValidSignature(amount, msg.sender, userId, signature)) revert IncorrectSignature();

        for (uint256 i; i < amount; ++i) {
            uint256 tokenId = tokenIds[i];

            if (msg.sender != ownerOf(tokenId)) revert IncorrectSender();
            claimedTokens[userId]--;
            _burn(tokenId);
        }
    }

    function setLocked(bool newLocked) external onlyOwner {
        soulbound = newLocked;
        if (newLocked) emit Locked(0);
        else emit Unlocked(0);
    }

    function setMintableAmountPerUser(uint256 newAmount) external onlyOwner {
        mintableAmountPerUser = newAmount;
        emit MintableAmountPerUserChanged(newAmount);
    }

    function updateTokenURI(string calldata newCid) external onlyOwner {
        cid = newCid;
        emit MetadataUpdate();
    }

    function balanceOf(uint256 userId) external view returns (uint256 amount) {
        return claimedTokens[userId];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);

        return string.concat("ipfs://", cid);
    }

    /// @notice Checks the validity of the signature for the given params.
    function isValidSignature(
        uint256 amount,
        address receiver,
        uint256 userId,
        bytes calldata signature
    ) internal view returns (bool) {
        if (signature.length != 65) revert IncorrectSignature();
        bytes32 message = keccak256(abi.encode(amount, receiver, userId, block.chainid, address(this)))
            .toEthSignedMessageHash();
        return message.recover(signature) == IGuildRewardNFTFactory(factoryProxy).validSigner();
    }
}
