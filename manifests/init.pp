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
#       'query' => '#node.report-timestamp < @"now - 2 hours"'
#     },
#     {
#       'name'  => 'Nodes in production env',
#       'type'  => 'success',
#       'query' => '#node.catalog-environment = production'
#     },
#     {
#       'name'  => 'Nodes in non-production env',
#       'type'  => 'warning',
#       'query' => '#node.catalog-environment != production'
#     }
#   ]
#
# [*manage_apt*]
#   Add apt repo for the module
#   Defaults to true for $::osfamily Debian
#
# [*manage_yum*]
#   Add yum repo for the module
#   Defaults to true for $::osfamily RedHat
#
# [*webserver_class*]
#   Name of the class where the webserver is configured
#   Default: '::puppetexplorer::apache'
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
  $package_ensure     = $::puppetexplorer::params::package_ensure,
  $ga_tracking_id     = $::puppetexplorer::params::ga_tracking_id,
  $ga_domain          = $::puppetexplorer::params::ga_domain,
  $puppetdb_servers   = $::puppetexplorer::params::puppetdb_servers,
  $node_facts         = $::puppetexplorer::params::node_facts,
  $unresponsive_hours = $::puppetexplorer::params::unresponsive_hours,
  $dashboard_panels   = $::puppetexplorer::params::dashboard_panels,
  $manage_repo        = $::puppetexplorer::params::manage_repo,
  $webserver_class    = $::puppetexplorer::params::webserver_class,
  $servername         = $::puppetexplorer::params::servername,
  $ssl                = $::puppetexplorer::params::ssl,
  $port               = $::puppetexplorer::params::port,
  $proxy_pass         = $::puppetexplorer::params::proxy_pass,
  $vhost_options      = $::puppetexplorer::params::vhost_options,
  $puppetdb_host      = $::puppetexplorer::params::puppetdb_host,
  $webserver_ip       = $::puppetexplorer::params::webserver_ip,
) inherits puppetexplorer::params {

  if $manage_repo {
    case $::osfamily {
      'Debian': {
        apt::source { 'puppetexplorer':
          location    => 'http://apt.puppetexplorer.io',
          release     => 'stable',
          repos       => 'main',
          key         => '3FF5E93D',
          include_src => false,
          before      => Package['puppetexplorer'],
        }
      }
      'RedHat': {
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
      }
      default: {fail("your \$osfamily has the value ${::osfamily} which isn't supported for managing the repo")}
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

  if ($webserver_class == 'apache') or ($webserver_class == '::puppetexplorer::apache'){
    include ::puppetexplorer::apache
  } elsif $webserver_class == 'nginx'{
    Class['nginx'] -> Class['::puppetexplorer::nginx']
    class { '::puppetexplorer::nginx':
      puppetdb_host => $puppetdb_host,
      hostname      => $servername,
      nginx_host    => $webserver_ip,
      nginx_port    => $port,
    }
  }
}
