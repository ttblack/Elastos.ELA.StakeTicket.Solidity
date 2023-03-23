/* External Imports */
const { ethers, network } = require('hardhat')
const chai = require('chai')
const { solidity } = require('ethereum-waffle')

var Web3 = require('web3')
var web3 = new Web3(network.provider)

const {
    setup, deployERC721, sleep
} = require("../scripts/utils/helper")
const {formatBytes32String} = require("ethers/lib/utils");
const {getRpcReceiptOutputsFromLocalBlockExecution} = require("hardhat/internal/hardhat-network/provider/output");

chai.use(solidity)

describe(`Stake Ticket Contact `, () => {


    let erc721Contract;
    let admin,user1,user2;
    before(`deploy contact `, async () => {
        let chainID = await getChainId();
        let accounts = await ethers.getSigners();
        [admin,user1,user2] = [accounts[0],accounts[1],accounts[2]];
        console.log("chainID is :" + chainID + " address :" + admin.address);
        erc721Contract = await deployERC721(
            "stakeNft",
            "nft",
            "",
            admin);
        console.log("erc721Contract.address", erc721Contract.address);

    })

    it('set miner role test', async function() {
        //keccak256("MINTER_ROLE");
        let  Role = web3.utils.keccak256("MINTER_ROLE");
         Role = web3.utils.hexToBytes(Role);
        let count = await erc721Contract.getRoleMemberCount(Role);
        let owner = 0;
        if (count > 0) {
            owner = await erc721Contract.getRoleMember(Role, 0);
        }

        console.log("before setMinterRole", "count", count, "owner", owner, "newOwner", user1.address);
        //
        let tx = await erc721Contract.setMinterRole(user1.address);
        console.log("setMinterRole tx", tx.hash);



        count = await erc721Contract.getRoleMemberCount(Role);
        owner = await erc721Contract.getRoleMember(Role, 0);
        console.log("behind setMinterRole", "count", count, "owner", owner);

         tx = await erc721Contract.setMinterRole(user2.address);
        console.log("setMinterRole2 tx", tx.hash, "newOwner", user2.address);

        count = await erc721Contract.getRoleMemberCount(Role);
        owner = await erc721Contract.getRoleMember(Role, 0);
        console.log("behind setMinterRole2", "count", count, "owner", owner,"user2",user2.address);

    })


    it('change owner test', async function() {
       let  Role = web3.utils.hexToBytes("0x0000000000000000000000000000000000000000000000000000000000000000")
        let count = await erc721Contract.getRoleMemberCount(Role);
        let owner = await erc721Contract.getRoleMember(Role, 0);
        console.log("before changeOwner", "count", count, "owner", owner, "newOwner", user1.address);

        let tx = await erc721Contract.changeAdminRole(user1.address);
        console.log("changeAdminRole tx", tx.hash);
        count = await erc721Contract.getRoleMemberCount(Role);
        owner = await erc721Contract.getRoleMember(Role, 0);
        console.log("behind changeOwner", "count", count, "owner", owner);

    })

    /
    it('change miner role test to mint', async function() {

        let tokenID = 1234;
        let  Role = web3.utils.keccak256("MINTER_ROLE");
        owner = await erc721Contract.getRoleMember(Role, 0);
        let count = await erc721Contract.getRoleMemberCount(Role);

        console.log("behind setMinterRole2", "count", count, "owner", owner,"user2",user2.address);

        await erc721Contract.connect(user2).mint(user1.address,tokenID,"0x12");
        let ownerOf = await erc721Contract.connect(user2).ownerOf(tokenID)

        //mint
        console.log("mint result owner of ", ownerOf,"user1",user1.address);

    })


})