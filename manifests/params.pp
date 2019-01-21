class rocketchat::params {
  $port           = 80
  $instance_count = 1
  $verbose        = false
  $manage_repos   = true
  $download_path  = '/tmp'
  $destination    = '/opt'
  $package_ensure = 'latest'
  $package_source = undef
  $mongo_host     = 'localhost'
  $mongo_port     = 27017
  $mongo_replset  = undef
  $authsource     = undef
  $nodejs_version = '4.x'
  $nodejs_deps    = true
  $database_name  = 'rocket_chat'
  $root_url       = 'http://rocket.com'
}
