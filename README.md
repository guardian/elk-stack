ELK Stack with Google OAuth
===========================

ELK stands for [Elasticsearch 2][1], [Logstash 2][2] and [Kibana 4][3] and is being promoted by Elasticsearch as a "devops" logging solution.

This implemenation of an ELK stack is designed to run in AWS EC2 VPC and is secured using Google OAuth 2.0. It consists of one or more instances behind an Elastic Load Balancer (ELB) running the following components:

* Kibana 4.x
* Elasticsearch 2.x
* Logstash 2.x indexer
* Node.js application proxy

Security
--------

Only the Logstash indexer and the application proxy ports are exposed on the ELB and all requests to the application proxy for Kibana or Elasticsearch are authenticated using Google OAuth.

Elasticsearch is configured to listen only on the local loopback address. Dynamic scripting has been disabled to address security concerns with [remote code execution][4] since elasticsearch version 1.4.3.

Healthcheck
-----------

The ELB requires a healthcheck to ensure instances in the load balancer are healthy. To achieve this, access to the root URL for Elasticsearch is available at the path `/__es` and it is *not* authenticated.

Log Shippers
------------

### via TCP

Shipping logs to the ELK stack via tcp is left as an exercise for the user however example configurations are included in the repo under the `/examples` directory. TBC

A very simple one that reads from stdin and tails a log file then echoes to stdout and forwards to the ELK stack is below:

```
$ logstash --debug -e '
input { stdin { } file { path => "/var/log/system.log" } }
output { stdout { } tcp { host => "INSERT-ELB-DNS-NAME-HERE" port => 6379 codec => json_lines } }'
```

### via a Kinesis Stream

Logstash is also setup to ingest logs via a Kinesis Stream using the [logstash-input-kinesis](https://github.com/codekitchen/logstash-input-kinesis) plugin.
You can find the Kinesis stream information in the Cloudformation stack output. 
The expected input codec is `json`.

VPC Configuration
-----------------

This ELK stack assumes your AWS VPC is configured as per AWS guidelines which is to have a public and private subnet in each availability zone for the region. See [Your VPC and Subnets][6] guide for more information.

The easiest way to ensure you have the required VPC setup would be to delete your existing VPC, if possible, and then use the [Start VPC Wizard][7] which will create a correctly configured VPC for you.

Installation
------------

1. Go to [Google Developer Console][5] and create a new client ID for a web application

   You can leave the URLs as they are and update them once the ELK stack has been created. Take note of the Client ID and Client Secret as you will need them in the next step.

2. Enable the "Google+ API" for your new client. This is the only Google API needed.

3. Launch the ELK stack using the AWS console or `aws` command-line tool and enter the required parameters. Note that some parameters, like providing a Route53 Hosted Zone Name to create a DNS alias for the public ELB, are optional.

4. Once the ELK stack has launched revisit the Google developer console and update the URLs copying the output for `GoogleOAuthRedirectURL` to `AUTHORIZED REDIRECT URI` and the same URL but without to path to `AUTHORISED JAVASCRIPT ORIGINS`.

Plugins
-------

The following elasticsearch plugins are installed:

  * [AWS Cloud plugin][8] - uses AWS API for the unicast discovery mechanism
  * [elasticsearch-head][9] - web frontend for elasticsearch cluster

The "head" plugin web page is available at proxied (ie. authenticated) endpoints based on how the ELK stack is deployed:

  * Head      -> `http://<ELB>/__es/_plugin/head/`

Configuration
-------------

This ELK stack cloudformation template takes many parameters, explainations for each are shown when launching the stack. Note that Route 53 DNS, EBS volumes and S3 snapshots are optional.

Logstash grok patterns can be tested online at https://grokdebug.herokuapp.com/

The Kibana dashboards are configured via the GUI.

License
-------

    Guardian ELK Stack Cloudformation Templates and Logcabin Proxy
    Copyright 2014-2016 Guardian News & Media

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

[1]: <https://www.elastic.co/> "Elasticsearch"
[2]: <https://www.elastic.co/products/logstash> "Logstash"
[3]: <https://www.elastic.co/products/kibana> "Kibana"
[4]: <http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-scripting.html> "ES Scripting"
[5]: <https://console.developers.google.com> "Google Developer Console"
[6]: <http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html> "AWS: Your VPC and Subnets"
[7]: <https://console.aws.amazon.com/vpc/>
[8]: <https://github.com/elastic/elasticsearch/tree/2.0/plugins/cloud-aws>
[9]: <http://mobz.github.io/elasticsearch-head/>

