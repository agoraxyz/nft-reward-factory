# SoulboundERC721

An enumerable soulbound ERC721.

Allowance and transfer-related functions are disabled.

Inheriting from upgradeable contracts here - even though we're using it in a non-upgradeable way,
we still want it to be initializable

## Functions

### __SoulboundERC721_init

```solidity
function __SoulboundERC721_init(
    string name_,
    string symbol_
) internal
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `name_` | string |  |
| `symbol_` | string |  |

### supportsInterface

```solidity
function supportsInterface(
    bytes4 interfaceId
) public returns (bool)
```

See {IERC165-supportsInterface}.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `interfaceId` | bytes4 |  |

### locked

```solidity
function locked(
    uint256 tokenId
) external returns (bool)
```

Returns the locking status of an Soulbound Token

SBTs assigned to zero address are considered invalid, and queries
about them do throw.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `tokenId` | uint256 | The identifier for an SBT. |

### approve

```solidity
function approve(
    address ,
    uint256 
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | uint256 |  |

### setApprovalForAll

```solidity
function setApprovalForAll(
    address ,
    bool 
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | bool |  |

### isApprovedForAll

```solidity
function isApprovedForAll(
    address ,
    address 
) public returns (bool)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | address |  |

### transferFrom

```solidity
function transferFrom(
    address ,
    address ,
    uint256 
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | address |  |
| `` | uint256 |  |

### safeTransferFrom

```solidity
function safeTransferFrom(
    address ,
    address ,
    uint256 
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | address |  |
| `` | uint256 |  |

### safeTransferFrom

```solidity
function safeTransferFrom(
    address ,
    address ,
    uint256 ,
    bytes 
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | address |  |
| `` | uint256 |  |
| `` | bytes |  |

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(
    address from,
    address to,
    uint256 firstTokenId,
    uint256 batchSize
) internal
```

Still used for minting/burning.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `from` | address |  |
| `to` | address |  |
| `firstTokenId` | uint256 |  |
| `batchSize` | uint256 |  |

## Custom errors

### NonExistentToken

```solidity
error NonExistentToken(uint256 tokenId)
```

Error thrown when trying to query info about a token that's not (yet) minted.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The queried id. |

### Soulbound

```solidity
error Soulbound()
```

Error thrown when a function's execution is not possible, because this is a soulbound NFT.

