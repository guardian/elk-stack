var request = require('request')
var passport = require('passport')
var GithubStrategy = require('passport-github').Strategy


exports.setupOAuth = function(express, app, config) {

    console.log('Github OAuth2 authentication used')

   
    passport.serializeUser(function(user, done) {
      done(null, user)
    })
    
    passport.deserializeUser(function(obj, done) {
      done(null, obj)
    })

    var callbackUrl = 'http://' + config.host + '/auth/github/callback'
    
    passport.use(new GithubStrategy({
            clientID: config.oauth_client_id,
            clientSecret: config.oauth_client_secret,
            callbackURL: callbackUrl
        }, function(accessToken, refreshToken, profile, done) {
            findUser(profile, accessToken, config, function(succeed, msg) {
                return succeed ? done(null, profile): done(null, false, { message: msg})
            })
    }))

    app.use(function(req, res, next) {
        if (req.session.authenticated || nonAuthenticated(config, req.url)) {
            return next()
        }
        req.session.beforeLoginURL = req.url
        res.redirect('/auth/github')
    })
    app.use(passport.initialize())
    app.use(passport.session())

    var scope = [ 'read:org' ]

    app.get('/auth/github',
        passport.authenticate('github', { scope: scope }),
            function(req, res) {
                /* do nothing as this request will be redirected to github for authentication */
            }
    )

    app.get('/auth/github/callback',
        passport.authenticate('github', { failureRedirect: '/auth/github/fail' }),
            function(req, res) {
                /* Successful authentication, redirect home. */
                req.session.authenticated = true
                res.redirect(req.session.beforeLoginURL || '/')
            }
    )

    app.get('/auth/github/fail', function(req, res) {
        res.statusCode = 403
        res.end('<html><body>Unauthorized</body></html>')
    })
}

function nonAuthenticated(config, url) {
    return url.indexOf('/auth/github') === 0 || config.oauth_unauthenticated.indexOf(url) > -1
}

function findUser(profile, accessToken, config, callback)  {
    var username = profile.username || 'unknown'

    var options = {
        url: profile._json.organizations_url,
        headers: {
            'User-Agent': config.oauth_application_name,
            'Authorization': 'token ' + accessToken 
        }
    }

    request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
            var orgs = JSON.parse(body)
            for(var i=0; i<orgs.length; i++) {
                if (orgs[i].login === 'guardian') {
                    return callback(true, username)
                }
            }
            console.log('access refused to: ' + username)
            return callback(false, username + ' is not authorized') 
        } else {
            console.log('unexpected error: ' + error + ' while trying to access organisations of ' + username)
            console.log('response status code: '  + response.statusCode)
            console.log('response body: ' + response.body)
            return callback(false, 'an unexpected error occurs')
        }
    })
}