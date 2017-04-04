class rocket::install(
  $download_path,
  $destination,
  $package_ensure
) {
  include wget
  include apt

  $file_path = "${download_path}/rocket.tgz"

  wget::fetch { 'Download stable Rocket.Chat package':
    source      => "https://rocket.chat/releases/${package_ensure}/download",
    destination => $file_path,
    verbose     => false,
    before      => Archive[$file_path],
    unless      => "test -d ${destination}/bundle/server",
  }

  file { $destination:
    ensure => directory,
  }

  archive { $file_path:
    path         => $file_path,
    extract      => true,
    extract_path => $destination,
    require      => File[$destination],
    creates      => "${destination}/bundle/server",
  }

  exec { 'npm install':
    cwd     => "${destination}/bundle/programs/server/",
    creates => "${destination}/bundle/programs/server/node_modules/",
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin:/root/bin',
    require => [Archive[$file_path], Class['rocket::packages']],
  }
}