// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Authorities {
    struct Authority {
        address addr;
        string name;
        string designation;
        string city;
    }
    mapping(uint => Authority) public authorities;
    uint public length;

    function addAuthority(
        string memory _name,
        string memory _designation,
        string memory _city
    ) public {
        uint id = length++;
        authorities[id] = Authority(
            msg.sender,
            _name,
            _designation,
            _city
        );
    }

    function assignCampaignToAuthority(
        string memory _addressString
    ) public view returns (address) {
        // assign the campaign to the authority if the addressString matches the authority's city
        for (uint i = 0; i < length; i++) {
            if (
                keccak256(abi.encodePacked(authorities[i].city)) ==
                keccak256(abi.encodePacked(_addressString))
            ) {
                return authorities[i].addr;
            }
        }
        // return the address of the authority in any random way
        return authorities[0].addr;
    }

    // verify if the address is of authority or not
    function isAuthority() public view returns (bool) {
        for (uint i = 0; i < length; i++) {
            if (authorities[i].addr == msg.sender) {
                return true;
            }
        }
        return false;
    }

    // get the authority details
    function getAuthorityDetails()
        public
        view
        returns (string memory, string memory, string memory)
    {
        for (uint i = 0; i < length; i++) {
            if (authorities[i].addr == msg.sender) {
                return (
                    authorities[i].name,
                    authorities[i].designation,
                    authorities[i].city
                );
            }
        }
    }
}