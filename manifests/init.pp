# == Class: puppetexplorer
#
# Manage the Puppet Explorer web interface. In the default configuration it
# should work if it is hosted on the same host as PuppetDB.
#
# === Parameters
#
# [*package_ensure*]
#   The ensure parameter of the puppetexplorer package. Default: present
#
# [*ga_tracking_id*]
#   Google Analytics tracking ID.
#
# [*ga_domain*]
#   Google Analytics domain setting. Default: auto
#
# [*puppetdb_servers*]
#   List of server name and URL tuples. Default: [ ['production', '/api'] ]
#
# [*node_facts*]
#   List of facts to display in node detail view.
#   Default: [ 'operatingsystem', 'operatingsystemrelease', 'manufacturer',
#              'productname', 'processorcount', 'memorytotal', 'ipaddress' ]
#
# [*unresponsive_hours*]
#   The amount of hours since the last check-in after which a node is considered
#   unresponsive.
#   Default: 2
# 
# [*manage_apt*]
#   Add apt repo for the module
#   Defaults to true for $::osfamily Debian
#
# [*servername*]
#   The Apache vhost servername. Default: $::fqdn
#
# [*ssl*]
#   If SSL should be turned on for the Aapche vhost. Default: true
#
# [*port*]
#   Port of the Apache vhost. Default: 443
#
# [*proxy_pass*]
#   Proxy pass configuration for Apache. This is useful to proxy the API to
#   PuppetDB through the same vhost that hosts Puppet Explorer. If they are not
#   proxied PuppetDB needs to have the Access-Control-Allow-Origin and
#   Access-Control-Expose-Headers "X-Records" headers.
#   See the proxy_pass parameter of apache::vhost in puppetlabs-apache for more
#   info on this.
#   Default: [{ 'path' => '/api/v4', 'url' => 'http://localhost:8080/v4' }]
#
# [*vhost_options*]
#   An additional hash of apache::vhost options, see puppetlabs-apache for more
#   info. Can be used for configuring authentication or SSL certificates for
#   example. Default: {}
#
# === Authors
#
# Erik Dalen <dalen@spotify.com>
#
# === Copyright
#
# Copyright 2014 Spotify
#
class puppetexplorer (
  $package_ensure     = present,
  $ga_tracking_id     = 'UA-XXXXXXXX-YY',
  $ga_domain          = 'auto',
  $puppetdb_servers   = [ ['production', '/api'] ],
  $node_facts         = [
    'operatingsystem',
    'operatingsystemrelease',
    'manufacturer',
    'productname',
    'processorcount',
    'memorytotal',
    'ipaddress'
  ],
  $unresponsive_hours = 2,
  $manage_apt         = $::osfamily ? {
    'Debian' => true,
    default  => false,
  },
  # Apache site options:
  $servername         = $::fqdn,
  $ssl                = true,
  $port               = 443,
  $proxy_pass         = [{ 'path' => '/api/v4', 'url' => 'http://localhost:8080/v4' }],
  $vhost_options      = {},
) {
  include apache
  
  if $manage_apt {
    apt::source { 'puppetexplorer':
      location    => 'http://apt.puppetexplorer.io',
      release     => 'stable',
      repos       => 'main',
      key         => '84F6BA52',
      include_src => false,
    }
  }

  package { 'puppetexplorer':
    ensure => $package_ensure,
  }

  file { '/usr/share/puppetexplorer/config.js':
    ensure  => file,
    content => template('puppetexplorer/config.js.erb'),
    require => Package['puppetexplorer'],
  }

  $base_vhost_options = {
    docroot         => '/usr/share/puppetexplorer',
    ssl             => $ssl,
    port            => $port,
    proxy_pass      => $proxy_pass,
    ssl_proxyengine => true,
  }

  create_resources ('apache::vhost', hash([$servername, $base_vhost_options]), $vhost_options)
}
