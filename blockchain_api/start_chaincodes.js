'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('SampleWebApp');
var express = require('express');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var http = require('http');
var util = require('util');
var app = express();
var expressJWT = require('express-jwt');
var jwt = require('jsonwebtoken');
var bearerToken = require('express-bearer-token');
var cors = require('cors');

require('./config.js');
var hfc = require('fabric-client');

var helper = require('./app/helper.js');
var createChannel = require('./app/create-channel.js');
var join = require('./app/join-channel.js');
var install = require('./app/install-chaincode.js');
var instantiate = require('./app/instantiate-chaincode.js');
var invoke = require('./app/invoke-transaction.js');
var query = require('./app/query.js');
var host = process.env.HOST || hfc.getConfigSetting('host');
var port = process.env.PORT || hfc.getConfigSetting('port');


var initFunction = async function() {
	var username = 'user1';
	var orgname = 'Org1';
	logger.debug('End point : /users');
	logger.debug('User name : ' + username);
	logger.debug('Org name  : ' + orgname);
	let response = await helper.getRegisteredUser(username, orgname, true);
	logger.debug('-- returned from registering the username %s for organization %s',username,orgname);
	if (response && typeof response !== 'string') {
		logger.debug('Successfully registered the username %s for organization %s',username,orgname);
	} else {
		logger.debug('Failed to register the username %s for organization %s with::%s',username,orgname,response);
	}
	try {
		logger.info('<<<<<<<<<<<<<<<<< C R E A T E  C H A N N E L >>>>>>>>>>>>>>>>>');;
		var channelName = 'mychannel';
		var channelConfigPath = "../artifacts/channel/mychannel.tx";
		logger.debug('Channel name : ' + channelName);
		logger.debug('channelConfigPath : ' + channelConfigPath); //../artifacts/channel/mychannel.tx
		await createChannel.createChannel(channelName, channelConfigPath, username, orgname);
		var waitTill = new Date(new Date().getTime() + 5 * 1000);
		while(waitTill > new Date()){}
	} catch(err) {
		logger.debug(err);
		logger.debug("Possibel channel is already created");
	}
	

	

	logger.info('<<<<<<<<<<<<<<<<< J O I N  C H A N N E L >>>>>>>>>>>>>>>>>');
	var peers = ["peer0.org1.example.com","peer1.org1.example.com"]
	let message = await join.joinChannel(channelName, peers, username, orgname);
	// logger.info(message);


	logger.debug('==================== INSTALL CHAINCODE ==================');
	var chaincodeName = "mycc";
	var chaincodePath = 'chaincode/assets_accounter';
	var chaincodeVersion = '0';
	var chaincodeType = "golang";
	logger.debug('peers : ' + peers); // target peers list
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('chaincodePath  : ' + chaincodePath);
	logger.debug('chaincodeVersion  : ' + chaincodeVersion);
	logger.debug('chaincodeType  : ' + chaincodeType);
	await install.installChaincode(peers, chaincodeName, chaincodePath, chaincodeVersion, chaincodeType, username, orgname);

	logger.debug('==================== INSTANTIATE CHAINCODE ==================');
	var fcn = 'initLedger';
	var args = [];
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);

	await instantiate.instantiateChaincode(peers, channelName, chaincodeName, chaincodeVersion, chaincodeType, fcn, args, username, orgname);
}

initFunction().then(function () {
	logger.info("Chaincode start finished");
	process.exit()
});