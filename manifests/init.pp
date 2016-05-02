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
# [*dashboard_panels*]
#   Custom dashboard panels. Should be an array of hashes containing the keys
#   name, query and type.
#   Default: [
#     {
#       'name'  => 'Unresponsive nodes',
#       'type'  => 'danger',
#       'query' => '#node.report_timestamp < @"now - 2 hours"'
#     },
#     {
#       'name'  => 'Nodes in production env',
#       'type'  => 'success',
#       'query' => '#node.catalog_environment = production'
#     },
#     {
#       'name'  => 'Nodes in non-production env',
#       'type'  => 'warning',
#       'query' => '#node.catalog_environment != production'
#     }
#   ]
#
# [*manage_apt*]
#   Add apt repo for the module
#   This option requires the `puppetlabs/apt` module
#   Defaults to true for $::osfamily Debian
#
# [*manage_yum*]
#   Add yum repo for the module
#   Defaults to true for $::osfamily RedHat
#
# [*manage_selinux*]
#   Manage SELinux capabilities
#   This option requires the `jfryman/selinux` module
#   Defaults to false
#
# [*webserver_class*]
#   Name of the class where the webserver is configured
#   Using `'::puppetexplorer::apache'` requires the `puppetlabs/apache` module.
#   Default: '::puppetexplorer::apache'
#
# [*servername*]
#   The Apache vhost servername. Default: $::fqdn
#
# [*ssl*]
#   If SSL should be turned on for the Apache vhost. Default: true
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
#   Default:
#     [
#       { 'path'         => '/api/pdb/query', 'url' => 'http://localhost:8080/pdb/query' },
#       { 'path'     => '/api/pdb/meta', 'url'  => 'http://localhost:8080/pdb/meta' },
#       { 'path' => '/api/metrics', 'url'   => 'http://localhost:8080/metrics' }
#     ]
#
# [*ssl_proxyengine*]
#   Specifies whether or not to use SSLProxyEngine in the vhost.
#   Valid values are 'true' and 'false'. Default: true
#
# [*vhost_options*]
#   An additional hash of apache::vhost options, see puppetlabs-apache for more
#   info. Can be used for configuring authentication or SSL certificates for
#   example. Default: {}
#
# === Authors
#
# Erik Dalen <erik.gustav.dalen@gmail.com>
#
# === Copyright
#
# Copyright 2014-2016 Erik Dalen
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
  $dashboard_panels   = [
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
  ],
  $manage_apt         = $::osfamily ? {
    'Debian' => true,
    default  => false,
  },
  $manage_yum         = $::osfamily ? {
    'RedHat' => true,
    default  => false,
  },
  $manage_selinux     = false,

  $webserver_class    = '::puppetexplorer::apache',

  # Apache site options:
  $servername         = $::fqdn,
  $ssl                = true,
  $port               = 443,
  $proxy_pass         = [
    { 'path' => '/api/pdb/query', 'url' => 'http://localhost:8080/pdb/query' },
    { 'path' => '/api/pdb/meta', 'url' => 'http://localhost:8080/pdb/meta' },
    { 'path' => '/api/metrics', 'url' => 'http://localhost:8080/metrics' }
  ],
  $ssl_proxyengine    = true,
  $vhost_options      = {},
) {

  if $manage_apt {
    apt::source { 'puppetexplorer':
      location    => 'http://apt.puppetexplorer.io',
      release     => 'stable',
      repos       => 'main',
      key         => 'CA37C758D0D8CD3AE9740C466F75C6183FF5E93D',
      include_src => false,
      before      => Package['puppetexplorer'],
    }
  }

  if $manage_yum {
    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetexplorer':
      ensure => file,
      source => 'puppet:///modules/puppetexplorer/RPM-GPG-KEY-puppetexplorer',
      before => Yumrepo['puppetexplorer'],
    }
    yumrepo { 'puppetexplorer':
      ensure        => present,
      descr         => 'Puppet Explorer',
      baseurl       => 'http://yum.puppetexplorer.io/',
      enabled       => true,
      gpgcheck      => 0,
      repo_gpgcheck => 1,
      gpgkey        => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetexplorer',
      before        => Package['puppetexplorer'],
    }
    if $manage_selinux {
      include '::selinux'
      selinux::boolean { 'httpd_can_network_connect': }
    }
  }

  package { 'puppetexplorer':
    ensure => $package_ensure,
  }

  file { '/usr/share/puppetexplorer/config.js':
    ensure  => file,
    mode    => '0644',
    content => template('puppetexplorer/config.js.erb'),
    require => Package['puppetexplorer'],
  }

  if $webserver_class {
    include $webserver_class
  }

}
