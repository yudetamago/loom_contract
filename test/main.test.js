//import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const Main = artifacts.require("Main");

contract("Main", async (accounts) => {
    beforeEach(async function () {
        this.instance = await Main.new();
        this.owner = accounts[0];
    });

    describe('createRoom', function () {
        it('creates room', async function () {
            const id = 1;
            const result = await this.instance.createRoom(id);
            result.logs[0].event.should.be.equal("CreateRoom");
            result.logs[0].args.owner.should.be.equal(this.owner);
            result.logs[0].args.id.should.be.bignumber.equal(id);
            result.logs[0].args.createdAt.should.be.bignumber.above(0);
        });
    });

    describe('postMessage', function () {
        it('posts message', async function () {
            const id = 1;
            const result = await this.instance.createRoom(id);
            result.logs[0].event.should.be.equal("CreateRoom");
            result.logs[0].args.owner.should.be.equal(this.owner);
            result.logs[0].args.id.should.be.bignumber.equal(id);
            result.logs[0].args.createdAt.should.be.bignumber.above(0);
        });
    });
});