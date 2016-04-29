# An example with basic auth enabled:
class { 'puppetexplorer':
  port => 8443,
  puppetdb_servers => [['puppetdb', 'api']],
  vhost_options => {
    directories => [
      {
        'path'           => '/usr/share/puppetexplorer',
        'auth_type'      => 'Basic',
        'auth_name'      => 'PuppetExplorer Portal',
        'auth_require'   => 'valid-user',
        'auth_user_file' => '/etc/puppetexplorer/passwd',
        'options'        => 'Indexes FollowSymLinks MultiViews',
      },
    ],
  },
}

file { '/etc/puppetexplorer':
  ensure => directory,
  owner  => 'apache',
  group  => 'apache',
  mode   => '0700',
}

file { '/etc/puppetexplorer/passwd':
  owner   => 'apache',
  group   => 'apache',
  mode    => '0400',
  content => 'admin:$apr1$ss9PwwCY$INUnYD89DGFjSnoMyZv8i0',
}
