/**
 * Created by toadkicker on 11/10/16.
 */
var config = require('../config.js'),
    Auth0Strategy = require('passport-auth0'),
    passport = require('passport');

exports.setup = function (express, app, config) {

    var callbackUrl = config.host + '/auth/auth0/callback';

    var strategy = new Auth0Strategy({
            domain: config.allowed_domain,
            clientID: config.client_id,
            clientSecret: config.client_secret,
            callbackURL: callbackUrl
        },
        function (accessToken, refreshToken, extraParams, profile, done) {
            // accessToken is the token to call Auth0 API (not needed in the most cases)
            // extraParams.id_token has the JSON Web Token
            // profile has all the information from the user
            return done(null, profile);
        }
    );

    passport.use(strategy);

    app.use(function (req, res, next) {
        var verifyApiKey = require('./auth.apikey');
        if (req.session.authenticated || nonAuthenticated(config, req.url) || verifyApiKey(config, req)) {
            return next()
        }
        req.session.beforeLoginURL = req.url;
        res.redirect('/auth/auth0');
    });

    app.get(callbackUrl,
        passport.authenticate('auth0', {failureRedirect: '/login'}),
        function (req, res) {
            if (!req.user) {
                throw new Error('user null');
            }
            res.redirect("/");
        }
    );

    app.get('/auth/auth0',
        passport.authenticate('auth0', {}), function (req, res) {
            res.redirect("/");
        });

    app.get('/auth/auth0/fail', function (req, res) {
        res.statusCode = 403;
        res.end('<html><body>Unauthorized</body></html>');
    })
};
