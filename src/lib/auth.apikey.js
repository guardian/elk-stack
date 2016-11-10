/**
 * Created by toadkicker on 11/10/16.
 */


exports.verifyApiKey = function (config, req) {
    var apiKey = req.headers['authorization'] || '';
    return (config.apiKey.length > 0 && "ApiKey " + config.apiKey === apiKey)
}