# == Class: puppetexplorer::apache
#
# Manage the Apache configuration for the Puppet Explorer web interface.
#
class puppetexplorer::apache {

  include ::apache

  $base_vhost_options = {
    docroot         => '/usr/share/puppetexplorer',
    ssl             => $::puppetexplorer::ssl,
    port            => $::puppetexplorer::port,
    proxy_pass      => $::puppetexplorer::proxy_pass,
    ssl_proxyengine => $::puppetexplorer::ssl_proxyengine,
  }

  create_resources ('apache::vhost', hash([$::puppetexplorer::servername, $base_vhost_options]), $::puppetexplorer::vhost_options)

}
