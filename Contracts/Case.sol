// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./DynamicNFT.sol";

contract Case {
    struct Campaign {
        string name;
        string description;
        string imageProof;
        string status;
        string completionImageProof;
        Location location;
        address assignedAuthority;
        string issueType;
        string addressString;
        uint creationTimeStamp;
        uint completionTimeStamp;
        uint verificationTimeStamp;
        uint resolutionTimeStamp;
        bool userNFTClaimed;
        bool authorityNFTClaimed;
        uint nftTokenId;
        uint userNFTClaimedAt;
        uint authorityNFTClaimedAt;
        string rejectReason;
        string notCompletedReason;
    }
    struct Location {
        string latitude;
        string longitude;
    }

    mapping(uint => Campaign) public campaigns;
    uint public length;
    mapping(address => uint[]) public userCampaigns;
    event LogCampaignCreated(
        uint indexed _campaignId,
        string _name,
        string _description,
        string _imageProof,
        string _status,
        Location _location,
        address _assignedAuthority,
        string _issueType,
        string _addressString,
        uint _creationTimeStamp
    );

    event LogCampaignVerified(
        uint indexed _campaignId,
        string _status,
        address _assignedAuthority,
        uint _verificationTimeStamp,
        string _rejectReason
    );

    event LogCampaignResolved(
        uint indexed _campaignId,
        string _status,
        string _completionImageProof,
        Location location,
        uint _resolutionTimeStamp
    );

    event LogCampaignCompleted(
        uint indexed _campaignId,
        string _imageProof,
        string _completionImageProof,
        string _status,
        uint _completionTimeStamp,
        string _notCompletedReason
    );

    function createCampaign(
        string memory _name,
        string memory _description,
        string memory _imageProof,
        Location memory _location,
        string memory _addressString,
        string memory _issueType,
        Authorities _authoritiesContract
    ) public {
        uint campaignId = length++;
        address assignedAuthority = _authoritiesContract
            .assignCampaignToAuthority(campaignId);
        campaigns[campaignId] = Campaign(
            _name,
            _description,
            _imageProof,
            "pending",
            "",
            _location,
            assignedAuthority,
            _issueType,
            _addressString,
            block.timestamp,
            0,
            0,
            0,
            false,
            false,
            0,
            0,
            0,
            "",
            ""
        );
        userCampaigns[msg.sender].push(campaignId);
        emit LogCampaignCreated(
            campaignId,
            _name,
            _description,
            _imageProof,
            "pending",
            _location,
            assignedAuthority,
            _issueType,
            _addressString,
            block.timestamp
        );
    }

    function verifyCampaign(uint _campaignId, string memory _status) public {
        Campaign storage campaign = campaigns[_campaignId];
        if (
            keccak256(abi.encodePacked(campaign.status)) ==
            keccak256(abi.encodePacked("pending"))
        ) {
            if (campaign.assignedAuthority == msg.sender) {
                if (
                    keccak256(abi.encodePacked(_status)) ==
                    keccak256(abi.encodePacked("verified")) ||
                    keccak256(abi.encodePacked(_status)) ==
                    keccak256(abi.encodePacked("rejected"))
                ) {
                    campaign.status = _status;
                    if(
                        keccak256(abi.encodePacked(_status)) ==
                        keccak256(abi.encodePacked("rejected"))
                    )
                    {
                        campaign.rejectReason = _status;
                    }
                    campaign.verificationTimeStamp = block.timestamp;
                    emit LogCampaignVerified(
                        _campaignId,
                        _status,
                        campaign.assignedAuthority,
                        block.timestamp,
                        campaign.rejectReason
                    );
                }
            }
        }
    }

    function resolveCampaign(
        uint _campaignId,
        string memory _completionImageProof,
        Location memory _location
    ) public {
        Campaign storage campaign = campaigns[_campaignId];
        if (
            keccak256(abi.encodePacked(campaign.status)) ==
            keccak256(abi.encodePacked("verified"))
        ) {
            if (campaign.assignedAuthority == msg.sender) {
                campaign.status = "resolved";
                campaign.resolutionTimeStamp = block.timestamp;
                campaign.completionImageProof = _completionImageProof;
                emit LogCampaignResolved(
                    _campaignId,
                    "resolved",
                    _completionImageProof,
                    _location,
                    block.timestamp
                );
            }
        }
    }

    function completeCampaign(uint _campaignId, string memory _status) public {
        Campaign storage campaign = campaigns[_campaignId];
        if (
            keccak256(abi.encodePacked(campaign.status)) ==
            keccak256(abi.encodePacked("resolved"))
        ) {
            if (
                keccak256(abi.encodePacked(_status)) ==
                keccak256(abi.encodePacked("completed")) ||
                keccak256(abi.encodePacked(_status)) ==
                keccak256(abi.encodePacked("notCompleted"))
            ) {
                campaign.status = _status;
                if(
                    keccak256(abi.encodePacked(_status)) ==
                    keccak256(abi.encodePacked("notCompleted"))
                )
                {
                    campaign.notCompletedReason = _status;
                }
                campaign.completionTimeStamp = block.timestamp;
                emit LogCampaignCompleted(
                    _campaignId,
                    campaign.imageProof,
                    campaign.completionImageProof,
                    _status,
                    block.timestamp,
                    campaign.notCompletedReason
                );
            }
        }
    }

    function getPendingCampaignsByUser()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory pendingCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("pending"))
            ) {
                pendingCampaigns[i] = campaign;
                i++;
            }
        }
        return pendingCampaigns;
    }

    function getVerifiedCampaignsByUser()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory verifiedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("verified"))
            ) {
                verifiedCampaigns[i] = campaign;
                i++;
            }
        }
        return verifiedCampaigns;
    }

    function getResolvedCampaignsByUser()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory resolvedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("resolved"))
            ) {
                resolvedCampaigns[i] = campaign;
                i++;
            }
        }
        return resolvedCampaigns;
    }

    function getCompletedCampaignsByUser()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory completedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("completed"))
            ) {
                completedCampaigns[i] = campaign;
                i++;
            }
        }
        return completedCampaigns;
    }

    function getNotCompletedCampaignsByUser()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory notCompletedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("notCompleted"))
            ) {
                notCompletedCampaigns[i] = campaign;
                i++;
            }
        }
        return notCompletedCampaigns;
    }

    // get rejected campaigns by user
    function getRejectedCampaignsByUser()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory rejectedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("rejected"))
            ) {
                rejectedCampaigns[i] = campaign;
                i++;
            }
        }
        return rejectedCampaigns;
    }

    function getPendingCampaignsByAuthority()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory pendingCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("pending")) &&
                campaign.assignedAuthority == msg.sender
            ) {
                pendingCampaigns[i] = campaign;
                i++;
            }
        }
        return pendingCampaigns;
    }

    function getVerifiedCampaignsByAuthority()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory verifiedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("verified")) &&
                campaign.assignedAuthority == msg.sender
            ) {
                verifiedCampaigns[i] = campaign;
                i++;
            }
        }
        return verifiedCampaigns;
    }

    function getResolvedCampaignsByAuthority()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory resolvedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("resolved")) &&
                campaign.assignedAuthority == msg.sender
            ) {
                resolvedCampaigns[i] = campaign;
                i++;
            }
        }
        return resolvedCampaigns;
    }

    function getCompletedCampaignsByAuthority()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory completedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("completed")) &&
                campaign.assignedAuthority == msg.sender
            ) {
                completedCampaigns[i] = campaign;
                i++;
            }
        }
        return completedCampaigns;
    }

    function getNotCompletedCampaignsByAuthority()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory notCompletedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("notCompleted")) &&
                campaign.assignedAuthority == msg.sender
            ) {
                notCompletedCampaigns[i] = campaign;
                i++;
            }
        }
        return notCompletedCampaigns;
    }

    function getRejectedCampaignsByAuthority()
        public
        view
        returns (Campaign[] memory)
    {
        Campaign[] memory rejectedCampaigns = new Campaign[](
            userCampaigns[msg.sender].length
        );
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                keccak256(abi.encodePacked(campaign.status)) ==
                keccak256(abi.encodePacked("rejected")) &&
                campaign.assignedAuthority == msg.sender
            ) {
                rejectedCampaigns[i] = campaign;
                i++;
            }
        }
        return rejectedCampaigns;
    }

    function claimNftByUserOnCampaignVerification(
        uint _campaignId,
        DynamicNFT _dynamicNFT
    ) public {
        Campaign storage campaign = campaigns[_campaignId];
        if (
            keccak256(abi.encodePacked(campaign.status)) ==
            keccak256(abi.encodePacked("verified")) &&
            !campaign.userNFTClaimed
        ) {
            _dynamicNFT.mint(
                _campaignId,
                campaign.name,
                campaign.description,
                campaign.imageProof
            );
            campaign.userNFTClaimed = true;
            campaign.userNFTClaimedAt = block.timestamp;

            // nft.mint(msg.sender, _campaignId);
            campaign.nftTokenId = _campaignId;
        } else {
            revert("Campaign is not verified yet or nft already claimed");
        }
    }

    function claimNftByAuthorityOnCampaignCompletion(uint _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        if (
            keccak256(abi.encodePacked(campaign.status)) ==
            keccak256(abi.encodePacked("completed")) &&
            campaign.authorityNFTClaimed == false
        ) {
            campaign.authorityNFTClaimed = true;
            campaign.authorityNFTClaimedAt = block.timestamp;
            // nft.mint(msg.sender, _campaignId);
            campaign.nftTokenId = _campaignId;
        } else {
            revert("Campaign is not completed yet or nft already claimed");
        }
    }

    function getAllNftTokenIdOfUserOrAuthority()
        public
        view
        returns (uint[] memory)
    {
        uint[] memory tokenIds = new uint[](userCampaigns[msg.sender].length);
        uint i = 0;
        for (uint j = 0; j < userCampaigns[msg.sender].length; j++) {
            uint campaignId = userCampaigns[msg.sender][j];
            Campaign storage campaign = campaigns[campaignId];
            if (
                campaign.nftTokenId != 0 &&
                (campaign.userNFTClaimed || campaign.authorityNFTClaimed)
            ) {
                tokenIds[i] = campaign.nftTokenId;
                i++;
            }
        }
        return tokenIds;
    }
}

