module.exports =  {
    'host': '@@LOGCABIN_HOST',
    'listen_port': 8080,
    'apiKey': '@@API_KEY',
    'cookie_secret': '@@COOKIE_SECRET',
    'oauth_unauthenticated': ['/__es/', '/__es/_cat/health'],
    'oauth_application_name': 'logcabin',
    'oauth_client_id': '@@CLIENT_ID',
    'oauth_client_secret': '@@CLIENT_SECRET',
    'allowed_domain': '@@ALLOWED_DOMAIN',
    'kibana_host': 'localhost',
    'kibana_port': 5601,
    'es_host': 'localhost',
    'es_port': 9200
}
