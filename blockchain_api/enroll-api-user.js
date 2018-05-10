'use strict';
var log4js = require('log4js');
var logger = log4js.getLogger('SampleWebApp');

require('./config.js');
var hfc = require('fabric-client');

var helper = require('./app/helper.js');
// var host = process.env.HOST || hfc.getConfigSetting('host');
// var port = process.env.PORT || hfc.getConfigSetting('port');
var caOrg = process.env.FABRIC_CA_API_ORG;
var caUser = process.env.FABRIC_CA_API_USER;
var caPass = process.env.FABRIC_CA_API_PASS;


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
        // let secret = await caClient.enroll({
        //  enrollmentID: caUser,
        //  enrollmentSecret: caPass,
        // });
        // logger.debug('Successfully enrolled the API user');
        user = await client.setUserContext({username:caUser, password:caPass});
        logger.debug('Successfully enrolled username %s  and setUserContext on the client object', caUser);
    }
    if(user && user.isEnrolled) {
        return user;
    } else {
        throw new Error('User was not enrolled ');
    }
}

// enrollApiUser().then(function () {
//     logger.info("API user has been enrolled");
//     process.exit()
// });
exports.enrollApiUser = enrollApiUser;
