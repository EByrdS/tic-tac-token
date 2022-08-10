var ethers = require('ethers');
var crypto = require('crypto');

var id = crypto.randomBytes(32).toString('hex');
var privateKey = "0x"+id;
console.log("ETH_ADDRESS_KEY_1="+privateKey);

var wallet = new ethers.Wallet(privateKey);
console.log("ETH_ADDRESS_1="+wallet.address);

var id = crypto.randomBytes(32).toString('hex');
var privateKey = "0x"+id;
console.log("ETH_ADDRESS_KEY_2="+privateKey);

var wallet = new ethers.Wallet(privateKey);
console.log("ETH_ADDRESS_2="+wallet.address);
