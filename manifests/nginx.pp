# Class: puppetexplorer::nginx
#
# This class installs and configures nginx + vhost
#
# Parameters:
#
# Actions:
#
# Requires:
# Class nginx
#
# Sample Usage:
#
class puppetexplorer::nginx (
  $puppetdb_host,
  $nginx_host,
  $nginx_port,
  $hostname,
){
  # hacky vhost
  file { 'puppetexplorer-vhost':
    path    => '/etc/nginx/sites-available/puppetexplorer',
    content => template('puppetexplorer/puppetexplorer.erb'),
  } ->
  file { 'enable-puppetexplorer-vhost':
    ensure  => link,
    path    => '/etc/nginx/sites-enabled/puppetexplorer',
    target  => '/etc/nginx/sites-available/puppetexplorer',
    notify  => Service['nginx'],
  }
}
