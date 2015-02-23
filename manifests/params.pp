# Class: puppetexplorer::params
#
# This class installs and configures parameters for Puppetexplorer
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

class puppetexplorer::params {
  $package_ensure     = present
  $ga_tracking_id     = 'UA-XXXXXXXX-YY'
  $ga_domain          = 'auto'
  $puppetdb_servers   = [ ['production', '/api'] ]
  $unresponsive_hours = 2
  $webserver_class    = '::puppetexplorer::apache'
  $servername         = $::fqdn
  $ssl                = true
  $port               = 443
  $proxy_pass         = [{ 'path' => '/api/v4', 'url' => 'http://localhost:8080/v4' }]
  $vhost_options      = {}
  $manage_repo        = false
  $puppetdb_host      = '127.0.0.1'
  $webserver_ip       = $::ipaddress
  $dashboard_panels   = [
    {   
      'name'  => 'Unresponsive nodes',
      'type'  => 'danger',
      'query' => '#node.report-timestamp < @"now - 2 hours"'
    },  
    {   
      'name'  => 'Nodes in production env',
      'type'  => 'success',
      'query' => '#node.catalog-environment = production'
    },  
    {   
      'name'  => 'Nodes in non-production env',
      'type'  => 'warning',
      'query' => '#node.catalog-environment != production'
    }   
  ]
  $node_facts         = [ 
    'operatingsystem',
    'operatingsystemrelease',
    'manufacturer',
    'productname',
    'processorcount',
    'memorytotal',
    'ipaddress'
  ]
}
