ELK Stack with Google OAuth
===========================

ELK stands for [Elasticsearch][1], [Logstash][2] and [Kibana][3] and is being promoted by Elasticsearch as a "devops" logging solution.

This implemenation of an ELK stack is designed to run in AWS EC2 VPC and is secured using Google OAuth 2.0. It consists of one or more instances behind an Elastic Load Balancer (ELB) running the following components:

* Logstash indexer
* Elasticsearch
* Node.js application proxy
* Kibana3

Security
--------

Only the Logstash indexer and the application proxy ports are exposed on the ELB and all requests to the application proxy for Kibana or Elasticsearch, except the ELB healthcheck (see below), are authenticated using Google OAuth.

Elasticsearch is configured to listen only on the local loopback address and has dynamic scripting disabled to address security concerns with [remote code execution][4].

Healthcheck
-----------

The ELB requires a healthcheck to ensure instances in the load balancer are healthy. To achieve this, access to the root URL for Elasticsearch is available at the path `/__es` and it is *not* authenticated.

Log Shippers
------------

Shipping logs to the ELK stack are left as an exercise for the user however example configurations are included in the repo under the `/examples` directory. TBC

A very simple one that reads from stdin and tails a log file then echoes to stdout and forwards to the ELK stack is below:

```
$ logstash --debug -e '
input { stdin { } file { path => "/var/log/system.log" } }
output { stdout { } tcp { host => "INSERT-ELB-DNS-NAME-HERE" port => 6379 codec => json_lines } }'
```

VPC Configuration
-----------------

This ELK stack assumes your AWS VPC is configured as per AWS guidelines which is to have a public and private subnet in each availability zone for the region. See [Your VPC and Subnets][6] for more information.

The easiest way to ensure you have the required VPC setup would be to delete your existing VPC, if possible, and then use the EC2 instance launch wizard which will create a correctly configured VPC for you.

Installation
------------

1. Go to [Google Developer Console][5] and create a new client ID for a web application

   You can leave the URLs as they are and update them once the ELK stack has been created. Take note of the Client ID and Client Secret as you will need them in the next step.

2. Launch the ELK stack using the AWS console or `aws` command-line tool and enter the required parameters. Note that some parameters, like providing a Route53 Hosted Zone Name to create a DNS alias for the public ELB, are optional.

3. Once the ELK stack has launched revisit the Google developer console and update the URLs copying the output for `GoogleOAuthRedirectURL` to `AUTHORIZED REDIRECT URI` and the same URL but without to path to `AUTHORISED JAVASCRIPT ORIGINS`.

Configuration
-------------

Logstash grok patterns can be tested online at https://grokdebug.herokuapp.com/

The Kibana dashboards are configured via the GUI.

License
-------

    Guardian ELK Stack Cloudformation Templates and Logcabin Proxy
    Copyright 2012 Guardian News & Media

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

[1]: <http://www.elasticsearch.org/> "Elasticsearch"
[2]: <http://logstash.net/> "Logstash"
[3]: <http://www.elasticsearch.org/overview/kibana/> "Kibana"
[4]: <http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-scripting.html> "ES Scripting"
[5]: <https://console.developers.google.com> "Google Developer Console"
[6]: <http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html> "AWS: Your VPC and Subnets"
