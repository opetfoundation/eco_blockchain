/**
 * Copyright 2017 IBM All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('SampleWebApp');
var express = require('express');
var session = require('express-session');
var bodyParser = require('body-parser');
var http = require('http');
var util = require('util');
var app = express();
var expressJWT = require('express-jwt');
var jwt = require('jsonwebtoken');
var bearerToken = require('express-bearer-token');
var cors = require('cors');
var uuidv4 = require('uuid/v4');

require('./config.js');
var hfc = require('fabric-client');

var helper = require('./app/helper.js');
var invoke = require('./app/invoke-transaction.js');
var query = require('./app/query.js');
var enrollApiUser = require('./enroll-api-user.js');
var host = process.env.HOST || hfc.getConfigSetting('host');
var port = process.env.PORT || hfc.getConfigSetting('port');

var peers = [process.env.PEER_HOST];
var chaincodeName = process.env.CHAINCODE_NAME;
var channelName = process.env.CHANNEL_NAME;
var caUser = process.env.FABRIC_CA_API_USER;
var caOrg = process.env.FABRIC_CA_API_ORG;

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// SET CONFIGURATONS ////////////////////////////
///////////////////////////////////////////////////////////////////////////////
app.options('*', cors());
app.use(cors());
//support parsing of application/json type post data
app.use(bodyParser.json());
//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({
	extended: false
}));
app.use(async function(req, res, next) {
	try {
		var user = await enrollApiUser.enrollApiUser();
		logger.debug(' ------>>>>>> new request for %s',req.originalUrl);
		req.username = caUser;
		req.orgname = caOrg;
		next();
	} catch(error) {
		next(error);
	}
});

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// START SERVER /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var server = http.createServer(app).listen(port, function() {});
logger.info('****************** SERVER STARTED ************************');
logger.info('***************  http://%s:%s  ******************',host,port);
server.timeout = 240000;

function getErrorMessage(field) {
	var response = {
		success: false,
		message: field + ' field is missing or Invalid in the request'
	};
	return response;
}

/*
 * Create the user record.
 * Returns the user UID.
 */
app.post('/users', async function(req, res) {
	logger.debug('==================== CREATE USER ==================');
	var data = JSON.stringify(req.body);
	logger.debug('End point : /users');
	if (!data) {
		res.json(getErrorMessage('\'data\''));
		return;
	}
	var uid = uuidv4().toString();
	var fcn = 'createUser';
	var args = [uid, data];
	logger.debug('channelName  : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);

	try{
		await invoke.invokeChaincode(peers, channelName, chaincodeName, fcn, args, req.username, req.orgname);
		let message = '{"data":{"UID":"' + uid +  '"}}'
		res.send(message);
	}
	catch(err){
		res.send('{"error": "' + err.message + '" }');
	}
});

/*
 * Retrieve the user by UID.
 */
app.get('/users/:uid', async function(req, res) {
	logger.debug('==================== RETRIEVE USER ==================');
	logger.debug('End point : /users/{xxx}');

	var uid = req.params.uid;
	var fcn = 'retrieveUser';
	var args = [uid];
	logger.debug('channelName  : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);
	if (!uid) {
		res.json(getErrorMessage('\'args\''));
		return;
	}
	try{
		let message = await query.queryChaincode(peers[0], channelName, chaincodeName, args, fcn, req.username, req.orgname);
		message = JSON.parse(message);
		message.type = "user"
		message = JSON.stringify(message);
		res.send(message);
	} catch(err) {
		res.send('{"error": "' + err.message + '" }');
	}
});

/*
 * Create the document for the user specified by UID.
 * Returns the document UID.
 */
app.post('/documents/:user_uid', async function(req, res) {
	logger.debug('==================== CREATE DOCUMENT ==================');
	var user_uid = req.params.user_uid;
	var data = JSON.stringify(req.body);
	logger.debug('End point : /documents/:user_uid');
	if (!data) {
		res.json(getErrorMessage('\'data\''));
		return;
	}
	var doc_uid = uuidv4().toString();
	var fcn = 'createDocument';
	var args = [user_uid, doc_uid, data];
	logger.debug('channelName  : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);

	try{
		await invoke.invokeChaincode(peers, channelName, chaincodeName, fcn, args, req.username, req.orgname);
		let message = '{"data":{"UID":"' + doc_uid +  '"}}'
		res.send(message);
	} catch(err) {
		res.send('{"error": "' + err.message + '" }');
	}
});

/*
 * Retrieve the document by user UID and document UID.
 */
app.get('/documents/:user_uid/:doc_uid', async function(req, res) {
	logger.debug('==================== RETRIEVE DOCUMENT ==================');
	logger.debug('End point : /documents/:user_uid/:doc_uid');

	var user_uid = req.params.user_uid;
	var doc_uid = req.params.doc_uid;
	var fcn = 'retrieveDocument';
	var args = [user_uid, doc_uid];
	logger.debug('channelName  : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);
	if (!doc_uid) {
		res.json(getErrorMessage('\'args\''));
		return;
	}
	try{
		let message = await query.queryChaincode(peers[0], channelName, chaincodeName, args, fcn, req.username, req.orgname);
		res.send(message);
	} catch(err) {
		res.send('{"error": "' + err.message + '" }');
	}
});

// Query on chaincode on target peers
// Sample code from the ballance transfer example, to be removed.
app.get('/channels/:channelName/chaincodes/:chaincodeName', async function(req, res) {
	logger.debug('==================== QUERY BY CHAINCODE ==================');
	var channelName = req.params.channelName;
	var chaincodeName = req.params.chaincodeName;
	let args = req.query.args;
	let fcn = req.query.fcn;
	let peer = req.query.peer;

	logger.debug('channelName : ' + channelName);
	logger.debug('chaincodeName : ' + chaincodeName);
	logger.debug('fcn : ' + fcn);
	logger.debug('args : ' + args);

	if (!chaincodeName) {
		res.json(getErrorMessage('\'chaincodeName\''));
		return;
	}
	if (!channelName) {
		res.json(getErrorMessage('\'channelName\''));
		return;
	}
	if (!fcn) {
		res.json(getErrorMessage('\'fcn\''));
		return;
	}
	if (!args) {
		res.json(getErrorMessage('\'args\''));
		return;
	}
	args = args.replace(/'/g, '"');
	args = JSON.parse(args);
	logger.debug(args);

	let message = await query.queryChaincode(peer, channelName, chaincodeName, args, fcn, req.username, req.orgname);
	res.send(message);
});

//  Query Get Block by BlockNumber
// Sample code from the ballance transfer example, to be removed.
app.get('/channels/:channelName/blocks/:blockId', async function(req, res) {
	logger.debug('==================== GET BLOCK BY NUMBER ==================');
	let blockId = req.params.blockId;
	let peer = req.query.peer;
	logger.debug('channelName : ' + req.params.channelName);
	logger.debug('BlockID : ' + blockId);
	logger.debug('Peer : ' + peer);
	if (!blockId) {
		res.json(getErrorMessage('\'blockId\''));
		return;
	}

	let message = await query.getBlockByNumber(peer, req.params.channelName, blockId, req.username, req.orgname);
	res.send(message);
});

// Query Get Transaction by Transaction ID
// Sample code from the ballance transfer example, to be removed.
app.get('/channels/:channelName/transactions/:trxnId', async function(req, res) {
	logger.debug('================ GET TRANSACTION BY TRANSACTION_ID ======================');
	logger.debug('channelName : ' + req.params.channelName);
	let trxnId = req.params.trxnId;
	let peer = req.query.peer;
	if (!trxnId) {
		res.json(getErrorMessage('\'trxnId\''));
		return;
	}

	let message = await query.getTransactionByID(peer, req.params.channelName, trxnId, req.username, req.orgname);
	res.send(message);
});

// Query Get Block by Hash
// Sample code from the ballance transfer example, to be removed.
app.get('/channels/:channelName/blocks', async function(req, res) {
	logger.debug('================ GET BLOCK BY HASH ======================');
	logger.debug('channelName : ' + req.params.channelName);
	let hash = req.query.hash;
	let peer = req.query.peer;
	if (!hash) {
		res.json(getErrorMessage('\'hash\''));
		return;
	}

	let message = await query.getBlockByHash(peer, req.params.channelName, hash, req.username, req.orgname);
	res.send(message);
});

//Query for Channel Information
// Sample code from the ballance transfer example, to be removed.
app.get('/channels/:channelName', async function(req, res) {
	logger.debug('================ GET CHANNEL INFORMATION ======================');
	logger.debug('channelName : ' + req.params.channelName);
	let peer = req.query.peer;

	let message = await query.getChainInfo(peer, req.params.channelName, req.username, req.orgname);
	res.send(message);
});

//Query for Channel instantiated chaincodes
// Sample code from the ballance transfer example, to be removed.
app.get('/channels/:channelName/chaincodes', async function(req, res) {
	logger.debug('================ GET INSTANTIATED CHAINCODES ======================');
	logger.debug('channelName : ' + req.params.channelName);
	let peer = req.query.peer;

	let message = await query.getInstalledChaincodes(peer, req.params.channelName, 'instantiated', req.username, req.orgname);
	res.send(message);
});

// Query to fetch all Installed/instantiated chaincodes
// Sample code from the ballance transfer example, to be removed.
app.get('/chaincodes', async function(req, res) {
	var peer = req.query.peer;
	var installType = req.query.type;
	logger.debug('================ GET INSTALLED CHAINCODES ======================');

	let message = await query.getInstalledChaincodes(peer, null, 'installed', req.username, req.orgname)
	res.send(message);
});

// Query to fetch channels
// Sample code from the ballance transfer example, to be removed.
app.get('/channels', async function(req, res) {
	logger.debug('================ GET CHANNELS ======================');
	logger.debug('peer: ' + req.query.peer);
	var peer = req.query.peer;
	if (!peer) {
		res.json(getErrorMessage('\'peer\''));
		return;
	}

	let message = await query.getChannels(peer, req.username, req.orgname);
	res.send(message);
});
