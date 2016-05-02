# puppetexplorer

#### Table of Contents

1. [Overview](#overview)
2. [Parameters](#parameters)

## Overview

Manage the Puppet Explorer web interface. In the default configuration it
should work if it is hosted on the same host as PuppetDB.

## Parameters

##### `package_ensure`
  The ensure parameter of the puppetexplorer package. Default: present

##### `ga_tracking_id`
  Google Analytics tracking ID.

##### `ga_domain`
  Google Analytics domain setting. Default: auto

##### `puppetdb_servers`
  List of server name and URL tuples. Default: [ ['production', '/api'] ]

##### `node_facts`
  List of facts to display in node detail view.
  Default: [ 'operatingsystem', 'operatingsystemrelease', 'manufacturer',
             'productname', 'processorcount', 'memorytotal', 'ipaddress' ]


##### `unresponsive_hours`
  The amount of hours since the last check-in after which a node is considered
  unresponsive.
  Default: 2

##### `dashboard_panels`
  Custom dashboard panels. Should be an array of hashes containing the keys
  name, query and type. Default:

    [
      {
        'name'  => 'Unresponsive nodes',
        'type'  => 'danger',
        'query' => '#node.report_timestamp < @"now - 2 hours"'
      },
      {
        'name'  => 'Nodes in production env',
        'type'  => 'success',
        'query' => '#node.catalog_environment = production'
      },
      {
        'name'  => 'Nodes in non-production env',
        'type'  => 'warning',
        'query' => '#node.catalog_environment != production'
      }
    ]

##### `manage_apt`
  Add apt repo for the module.
  This option requires the `puppetlabs/apt` module.
  Defaults to true for $::osfamily Debian

##### `manage_yum`
  Add yum repo for the module.
  Defaults to true for $::osfamily RedHat

##### `manage_selinux`
   Manage SELinux capabilities
   This option requires the `jfryman/selinux` module
   Defaults to false

##### `webserver_class`
  Name of the class that manages the webserver configuration.
  Using `'::puppetexplorer::apache'` requires the `puppetlabs/apache` module.
  Defaults to '::puppetexplorer::apache'

##### `servername`
  The Apache vhost servername. Default: $::fqdn

##### `ssl`
  If SSL should be turned on for the Apache vhost. Default: true

##### `port`
  Port of the Apache vhost. Default: 443

##### `proxy_pass`
  Proxy pass configuration for Apache. This is useful to proxy the API to
  PuppetDB through the same vhost that hosts Puppet Explorer. If they are not
  proxied PuppetDB needs to have the Access-Control-Allow-Origin and
  Access-Control-Expose-Headers "X-Records" headers.
  See the proxy_pass parameter of apache::vhost in puppetlabs-apache for more
  info on this.

  Default:

    [
      { 'path'         => '/api/pdb/query', 'url' => 'http://localhost:8080/pdb/query' },
      { 'path'     => '/api/pdb/meta', 'url'  => 'http://localhost:8080/pdb/meta' },
      { 'path' => '/api/metrics', 'url'   => 'http://localhost:8080/metrics' }
    ]

##### `vhost_options`
  An additional hash of apache::vhost options, see puppetlabs-apache for more
  info. Can be used for configuring authentication or SSL certificates for
  example. Default: {}
