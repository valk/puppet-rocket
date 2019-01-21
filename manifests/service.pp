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

    # In the default case of one instance, create it as a single Service[rocket]
    # resource exactly as it was in older version of the module for backwards
    # compatibility.
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

    # For consistency with the new resources of multiple instances, also create
    # a stub Service["rocket@${port}"] resource.
    file { '/etc/systemd/system/rocket@.service':
      ensure  => 'file',
      require => Service['rocket'],
      content => "
      [Unit]
      BindsTo=rocket.service
      After=rocket.service
      [Service]
      Type=oneshot
      ExecStart=/bin/true
      RemainAfterExit=yes
      [Install]
      WantedBy=rocket.service
      "
    }
  } else {

    file { '/etc/systemd/system/rocket@.service':
      ensure  => 'file',
      content => template("${module_name}/rocket.service.erb")
    }
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
