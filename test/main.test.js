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
        this.room_id = 1;
    });

    describe('createRoom', function () {
        it('creates room', async function () {
            const result = await this.instance.createRoom(this.room_id);
            result.logs[0].event.should.be.equal("CreateRoom");
            result.logs[0].args.owner.should.be.equal(this.owner);
            result.logs[0].args.id.should.be.bignumber.equal(this.room_id);
            result.logs[0].args.createdAt.should.be.bignumber.above(0);
        });
    });

    describe('postMessage', function () {
        it('posts message', async function () {
            const text = "test";
            await this.instance.createRoom(this.room_id);
            const result = await this.instance.postMessage(this.room_id, text);
            result.logs[0].event.should.be.equal("PostMessage");
            result.logs[0].args.room_id.should.be.bignumber.equal(this.room_id);
            result.logs[0].args.owner.should.be.equal(this.owner);
            result.logs[0].args.kind.should.be.bignumber.equal(0);
            result.logs[0].args.text.should.be.equal(text);
            result.logs[0].args.createdAt.should.be.bignumber.above(0);
        });
    });

    describe('getMessages', function () {
        it('get messages', async function () {
            const text = "test";
            await this.instance.createRoom(this.room_id);
            await this.instance.postMessage(this.room_id, text);

            const messages = await this.instance.getMessages(this.room_id);
            messages[0][0].should.be.bignumber.equal(0);
            messages[1][0].should.be.equal(this.owner);
            //web3.toAscii(messages[2][0]).should.be.equal(text);
        });
    });
});