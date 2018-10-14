# Class that restarts services that are used by Rocket.Chat
# TODO: Check what distro are we running and adjust service file configuration
class rocketchat::service (
  $port,
  $mongo_host,
  $database_name,
  $root_url,
  $user_presence_monitor,
  $destination,
  $mongo_port,
  $mongo_replset,
  $authsource,
  $instance_count = 1,
  $instance_ip = undef
) {

  if ($mongo_host == 'localhost') {
    service { 'mongod':
      ensure => 'running',
      enable => true,
    }
  }

  if $instance_count == 1 {

    file { '/etc/systemd/system/rocket.service':
      ensure  => 'file',
      content => template("${module_name}/rocket.service.erb")
    }

    service { 'rocket':
      ensure  => 'running',
      enable  => true,
      require => File['/etc/systemd/system/rocket.service']
    }
    if defined(Service['mongod']) {
      Service['mongod'] -> Service['rocket']
    }
  } else {

    file { '/etc/systemd/system/rocket@.service':
      ensure  => 'file',
      content => template("${module_name}/rocket.service.erb")
    }

    Integer[$port, ($port + $instance_count - 1)].each |$instance_port| {
      service { "rocket@${instance_port}":
        ensure  => 'running',
        enable  => true,
        require => File['/etc/systemd/system/rocket@.service']
      }
      if defined(Service['mongod']) {
        Service['mongod'] -> Service["rocket@${instance_port}"]
      }
    }
  }
}
