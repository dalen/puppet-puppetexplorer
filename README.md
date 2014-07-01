# puppetexplorer

#### Table of Contents

1. [Overview](#overview)
2. [Parameters](#parameters)

## Overview

Manage the Puppet Explorer web interface. In the default configuration it
should work if it is hosted on the same host as PuppetDB.

## Parameters

#####`package_ensure`
  The ensure parameter of the puppetexplorer package. Default: present

#####`ga_tracking_id`
  Google Analytics tracking ID.

#####`ga_domain`
  Google Analytics domain setting. Default: auto

#####`puppetdb_servers`
  List of server name and URL tuples. Default: [ ['production', '/api'] ]

#####`servername`
  The Apache vhost servername. Default: $::fqdn

#####`ssl`
  If SSL should be turned on for the Aapche vhost. Default: true

#####`port`
  Port of the Apache vhost. Default: 443

#####`proxy_pass`
  Proxy pass configuration for Apache. This is useful to proxy the API to
  PuppetDB through the same vhost that hosts Puppet Explorer. If they are not
  proxied PuppetDB needs to have the Access-Control-Allow-Origin and
  Access-Control-Expose-Headers "X-Records" headers.
  See the proxy_pass parameter of apache::vhost in puppetlabs-apache for more
  info on this.
  Default: [{ 'path' => '/api/v4', 'url' => 'http://localhost:8080/v4' }]

#####`vhost_options`
  An additional hash of apache::vhost options, see puppetlabs-apache for more
  info. Can be used for configuring authentication or SSL certificates for
  example. Default: {}

