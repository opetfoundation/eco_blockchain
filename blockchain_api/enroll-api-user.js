'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('SampleWebApp');

require('./config.js');
var hfc = require('fabric-client');

var helper = require('./app/helper.js');
var caOrg = process.env.FABRIC_CA_API_ORG;
var caUser = process.env.FABRIC_CA_API_USER;
var caPass = process.env.FABRIC_CA_API_PASS;

/*
 * Enroll the API user with Fabric CA.
 *
 * Used for main network setup to enroll the API user when the API is first started.
 * On following runs just makes sure that the user is enrolled.
 */
var enrollApiUser = async function() {
    logger.info('Create CA Client');
    var client = await helper.getClientForOrg(caOrg);

    logger.info('Get user context');
    var user = await client.getUserContext(caUser, true);
    if (user && user.isEnrolled()) {
        logger.info('Successfully loaded member from persistence');
    } else {
        logger.info('Enrolling API user');
        let caClient = client.getCertificateAuthority();
        user = await client.setUserContext({username:caUser, password:caPass});
        logger.debug('Successfully enrolled username %s  and setUserContext on the client object', caUser);
    }
    if(user && user.isEnrolled) {
        return user;
    } else {
        throw new Error('User was not enrolled ');
    }
}

exports.enrollApiUser = enrollApiUser;
