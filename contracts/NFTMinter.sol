// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

error RequestNotFound();
contract NFTMinter is ERC721URIStorage, VRFConsumerBaseV2, ConfirmedOwner {
    event NFTGenerated(uint256 indexed requestId, address indexed owner);
    event NFTMinted(uint256 indexed tokenId, address indexed owner);

    mapping(uint256 => address) public senderByRequestId;

    VRFCoordinatorV2Interface private immutable COORDINATOR;
    uint64 private immutable subscriptionId;
    bytes32 private immutable keyHash;
    uint32 private constant CALLBACK_GAS_LIMIT = 500000;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private lastTokenId;
    uint64 private constant UNIQUE_NFTS = 16;

    constructor(uint64 _subscriptionId, address vrfCoordinatorAddress, bytes32 _keyHash) 
        ERC721("Animals in tuxedo", "AIT") VRFConsumerBaseV2(vrfCoordinatorAddress) ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            vrfCoordinatorAddress
        );
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        lastTokenId = 0;
    }

    // Assumes the subscription is funded sufficiently.
    function generateNFT() external onlyOwner returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            REQUEST_CONFIRMATIONS,
            CALLBACK_GAS_LIMIT,
            NUM_WORDS
        );

        senderByRequestId[requestId] = msg.sender;
        emit NFTGenerated(requestId, msg.sender);

        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        if(senderByRequestId[_requestId] == address(0))
            revert RequestNotFound();
        
        address nftOwner = senderByRequestId[_requestId];
        uint256 uniqueNftId = _randomWords[0] % UNIQUE_NFTS;

        lastTokenId++;
        uint256 tokenId = lastTokenId; // to save gas
        _safeMint(nftOwner, tokenId);
        _setTokenURI(tokenId, getTokenUriByUniqueId(uniqueNftId));

        emit NFTMinted(tokenId, nftOwner);
    }

    function getTokenUriByUniqueId(uint256 uniqueNftId) public pure returns (string memory) {
        if(uniqueNftId == 0)
            return "ipfs://QmexaUSpvZzS2cXonjDwQtoo5yToMu97fdGL6Jp4Szgwvh";
        else if(uniqueNftId == 1)
            return "ipfs://QmcdDvrFdJKFr8jGKGvgvZdTFgSY7K2B1K1pev3aTEhv9i";
        else if(uniqueNftId == 2)
            return "ipfs://QmfJ9d5UmTWTPdCSfhKqLPSrZ38jGrHZbXck5PMAoqgp28";
        else if(uniqueNftId == 3)
            return "ipfs://QmW4NLJReF1TyxF6sr7G8v11j5MbBTJPPaX3WFn4e5cMim";
        else if(uniqueNftId == 4)
            return "ipfs://QmU1vCYHjKgLqRSGNPRMvkki75EBtXxidt2MHMwudxeNeX";
        else if(uniqueNftId == 5)
            return "ipfs://QmfTHATm153J2jbxmLFeEibtktfUvC27NTNLryugRzeBtL";
        else if(uniqueNftId == 6)
            return "ipfs://Qmb4oPnAH5D4br5UqFdQnD8Tu4QAZ5CBSMbkApkiTqzwHQ";
        else if(uniqueNftId == 7)
            return "ipfs://QmcxbBQExNM8Mjvn3iWgZxeKjDo8NJuBK5j5nUUqsdqQ78";
        else if(uniqueNftId == 8)
            return "ipfs://QmNu7jgPjyBSCY2cRqTjqHHELbNPEht2FzFuoFKyBQrTKa";
        else if(uniqueNftId == 9)
            return "ipfs://QmPHL6KNKijZ3gxZV9fFXwvDScvdq7tEuHThU44t2ye1BB";
        else if(uniqueNftId == 10)
            return "ipfs://QmNyxg5bpQBKzJCJu82cZRFvBuJfa4LiDfNh4Fc85eF2z1";
        else if(uniqueNftId == 11)
            return "ipfs://QmedsPpFLSex9kcRmWABGR12WKg1iSvbsMRussxho6DXre";
        else if(uniqueNftId == 12)
            return "ipfs://QmbFg14W2qJG4ExAjPS44osXjRbFnm9gbNoMYX4woMb1Yj";
        else if(uniqueNftId == 13)
            return "ipfs://QmbhwQYeLozdvvh3L3DontCEx8AGMA5A7pEhoAn7mAYozi";
        else if(uniqueNftId == 14)
            return "ipfs://QmbmRHwRQLDZoF5wpMM5zYJQCZxJgqtvi3xxoWP8Lpba72";
        else
            return "ipfs://QmXjaphenmjYMedNeQJgKbgA6oGqrh4jyAu6gQP8ai88Wq";
    }
}