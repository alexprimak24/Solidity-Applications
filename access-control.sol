// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract AccessControl {
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);
    //role => account => bool
    //bytes32 as we gonna hash the name of the role which will save some gas
    mapping(bytes32 => mapping(address => bool)) public roles;

    //define admin role
    //by making private we use a bit less gas
    //constants usually uppercase.
    //made it public to compute hash and then set to private
    //0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    //0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
    bytes32 private constant USER = keccak256(abi.encodePacked("USER"));

    //with that modifier there is a question, how would we actually create an admin?
    //and for that purpose we made a constructor below
    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorized");
        _;
    }

    constructor() {
        _grantRole(ADMIN, msg.sender);
    }
    //made internal so an inherited contract would also be able to call it
    function _grantRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = true;
        emit GrantRole(_role,_account);
    }
    //we only want an admin to grant the role so we create a modifier to check if the caller has ADMIN role
    function grantRole(bytes32 _role, address _account) external onlyRole(ADMIN){
        _grantRole(_role, _account);
    }
    //function to revoke the role
    function revokeRole(bytes32 _role, address _account) external onlyRole(ADMIN){
        roles[_role][_account] = false;
        emit GrantRole(_role,_account);
    }

}

