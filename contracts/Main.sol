pragma solidity 0.4.23;

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;
}

// File: contracts/zeppelin-solidity/contracts/token/ERC721/ERC721.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
    function tokenByIndex(uint256 _index) public view returns (uint256);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function tokenURI(uint256 _tokenId) public view returns (string);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

contract CrystalBaseIF is ERC721 {
    function _transferFrom(address _from, address _to, uint256 _tokenId) public;
}

contract Main {
    struct Room {
        address owner;
        uint256 createdAt;
    }

    struct Message {
        uint256 kind;
        address owner;
        string text;
        uint256 createdAt;
        CrystalBaseIF crystal;
        uint256 tokenId;
    }

    mapping(uint256 => Room) internal rooms;
    mapping(uint256 => Message[]) internal messages;
    uint56 current_room_id = 0;

    event CreateRoom(address indexed owner, uint256 id, uint256 createdAt);
    event PostMessage(uint256 indexed room_id, address indexed owner, uint256 kind, string text, uint256 createdAt);

    function createRoom(uint256 _id) external returns(uint256) {
        //uint256 _id = current_room_id;
        Room memory _room = Room({
            owner: msg.sender,
            createdAt: now
        });
        rooms[_id] = _room;
        emit CreateRoom(msg.sender, _id, now);
        //current_room_id = current_room_id + 1;
        return _id;
    }

    function postMessage(uint256 _room_id, string _text) external {
        require(rooms[_room_id].createdAt > 0, "room not found");

        Message memory _message;
        _message.kind = 0;
        _message.owner = msg.sender;
        _message.text = _text;
        _message.createdAt = now;

        messages[_room_id].push(_message);
        emit PostMessage(_room_id, msg.sender, 0, _text, now);
    }

    function postTip(uint256 _room_id, CrystalBaseIF _crystal, uint256 tokenId) external {
        require(rooms[_room_id].createdAt > 0, "room not found");
        require(tokenId > 0, "tokens is 0");

        Message memory _message;
        _message.kind = 1;
        _message.owner = msg.sender;
        _message.crystal = _crystal;
        _message.tokenId = tokenId;
        _message.createdAt = now;

        _crystal._transferFrom(msg.sender, rooms[_room_id].owner, tokenId);
        messages[_room_id].push(_message);
    }

    function getRoom(uint256 _room_id) external view returns(
        address owner,
        uint256 createdAt
    ) {
        require(rooms[_room_id].createdAt > 0, "room not found");

        owner = rooms[_room_id].owner;
        createdAt = rooms[_room_id].createdAt;
    }

    function getMessages(uint256 _room_id) external view returns(
        uint256[] kind,
        address[] owner,
        bytes32[] text,
        uint256[] createdAt,
        CrystalBaseIF[] crystal,
        uint256[] tokenId
    ) {

        require(rooms[_room_id].createdAt > 0, "room not found");

        uint256 _len = messages[_room_id].length;

        kind = new uint256[](_len);
        owner = new address[](_len);
        text = new bytes32[](_len);
        createdAt = new uint256[](_len);
        crystal = new CrystalBaseIF[](_len);
        tokenId = new uint256[](_len);

        for(uint256 i = 0; i < _len; i++) {
            kind[i] = messages[_room_id][i].kind;
            owner[i] = messages[_room_id][i].owner;
            text[i] = s2b(messages[_room_id][i].text);
            createdAt[i] = messages[_room_id][i].createdAt;
            crystal[i] = messages[_room_id][i].crystal;
            tokenId[i] = messages[_room_id][i].tokenId;
        }
    }

    function s2b(string s) internal pure returns (bytes32) {
        bytes memory b = bytes(s);
        uint r = 0;
        for (uint i = 0; i < 32; i++) {
            if (i < b.length) {
                r = r | uint(b[i]);
            }
            if (i < 31) r = r * 256;
        }
        return bytes32(r);
    }
}