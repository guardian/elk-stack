var request = require('request')
var passport = require('passport')
var GoogleStrategy = require('passport-google-oauth').OAuth2Strategy


exports.setup = function(express, app, config) {

    console.log('Google OAuth2 authentication used')


    passport.serializeUser(function(user, done) {
      done(null, user)
    })

    passport.deserializeUser(function(obj, done) {
      done(null, obj)
    })

    var callbackUrl = config.host + '/auth/google/callback'

    passport.use(new GoogleStrategy({
            clientID: config.oauth_client_id,
            clientSecret: config.oauth_client_secret,
            callbackURL: callbackUrl
        }, function(accessToken, refreshToken, profile, done) {
            findUser(profile, accessToken, config, function(succeed, msg) {
                return succeed ? done(null, profile): done(null, false, { message: msg})
            })
    }))

    app.use(function(req, res, next) {
        if (req.session.authenticated || nonAuthenticated(config, req.url) || verifyApiKey(config, req)) {
            return next()
        }
        req.session.beforeLoginURL = req.url
        res.redirect('/auth/google')
    })
    app.use(passport.initialize())
    app.use(passport.session())


    var scope = ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email']

    app.get('/auth/google',
        passport.authenticate('google', { scope: scope }),
            function(req, res) {
                /* do nothing as this request will be redirected to google for authentication */
            }
    )

    app.get('/auth/google/callback',
        passport.authenticate('google', { failureRedirect: '/auth/google/fail' }),
            function(req, res) {
                /* Successful authentication, redirect home. */
                req.session.authenticated = true
                res.redirect(req.session.beforeLoginURL || '/')
            }
    )

    app.get('/auth/google/fail', function(req, res) {
        res.statusCode = 403
        res.end('<html><body>Unauthorized</body></html>')
    })
}

function nonAuthenticated(config, url) {
    return url.indexOf('/auth/google') === 0 || config.oauth_unauthenticated.indexOf(url) > -1
}

function findUser(profile, accessToken, config, callback)  {
    var username = profile.displayName || 'unknown';
    var email = profile.emails[0].value || '';
    var domain = profile._json.domain || '';

    if ( (  email.split('@')[1] === config.allowed_domain ) || domain === config.allowed_domain ) {
        return callback(true, username)
    } else {
        console.log('access refused to: ' + username + ' (email=' + email + ';domain=' + domain + ')');
        return callback(false, username + ' is not authorized')
    }
}

function verifyApiKey(config, req)  {
    var apiKey = req.headers['authorization'] || '';
    return (config.apiKey.length > 0 && "ApiKey " + config.apiKey === apiKey)
}
