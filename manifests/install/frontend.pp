# Class: tct::install::frontend
# ===========================
#
# Full description of class tct here.
#
#
# Examples
# --------
#
#
# Authors
# -------
#
# Flannon Jackson <flannon@nyu.edu>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class tct::install::frontend (
  String $allowed_hosts = lookup('tct::allowed_hosts', String, 'first'),
  String $backend       = lookup('tct::backend', String, 'first'),
  String $backend_revision = lookup('tct::backend_revision', String, 'first'),
  String $basename      = lookup('tct::basename', String, 'first'),
  String $baseurl       = lookup('tct::baseurl', String, 'first'),
  String $db_host       = lookup('tct::db_host', String, 'first'),
  String $db_password   = lookup('tct::db_password', String, 'first'),
  String $db_user       = lookup('tct::db_user', String, 'first'),
  String $epubs_src_folder = lookup('tct::epubs_src_folder', String, 'first'),
  String $frontend      = lookup('tct::frontend', String, 'first'),
  String $frontend_revision = lookup('tct::frontend_revision', String, 'first'),
  String $install_dir   = lookup('tct::install_dir', String, 'first'),
  String $media_root    = lookup('tct::media_root', String, 'first'),
  String $pub_src       = lookup('tct::pub_src', String, 'first'),
  String $secret_key    = lookup('tct::secret_key', String, 'first'),
  String $static_root   = lookup('tct::static_root', String, 'first'),
  String $tct_db        = lookup('tct::tct_db', String, 'first'),
  String $user          = lookup('tct::user', String, 'first'),
  String $venv          = lookup('tct::venv', String, 'first'),
  String $www_dir       = lookup('tct::www_dir', String, 'first'),
){

  class { 'nodejs':
    repo_url_suffix            => '7.x',
    nodejs_package_name        => 'nodejs-2:7.7.4-1nodesource.el7.centos.x86_64'
  }
  #vcsrepo { "${install_dir}/${frontend}":
  vcsrepo { $www_dir:
    ensure   => present,
    provider => git,
    source   => "https://github.com/NYULibraries/${frontend}",
    revision => $frontend_revision,
    owner    => 'vagrant',
    group    => 'vagrant',
  }
  file { 'root_bowerrc' :
    ensure  => file,
    path    => '/root/.bowerrc',
    content => template('tct/bowerrc.erb'),
    owner   => 'root',
    group   => 'root',
  }
  file { 'settings.js':
    ensure  => file,
    path    => "${www_dir}/src/js/angular/settings.js",
    require => Vcsrepo["$www_dir"],
    content => template('tct/settings.js.erb'),
  }

  package { 'bower':
    #ensure  => '1.8.2',
    ensure   => '1.8.0',
    #
    provider => 'npm',
    require  => Class['nodejs'],
  }
  package { 'gulp-cli':
    ensure   => present,
    provider => 'npm',
    require  => Class['nodejs'],
  }
  
  exec { 'exec_npm_install_bower' :
    path       => ["${venv}/bin",'/bin','/usr/bin','/usr/local/bin'],
    cwd        => $www_dir,
    command    => '/usr/bin/npm install -g bower',
    #creates    => "${www_dir}/node_modules",
    #require    => [ Class['nginx'], Vcsrepo["$www_dir"] ],
    user       => 'root',
    require    => Class['nodejs'],
  }
  exec { 'exec_npm_install' :
    path       => ["${venv}/bin",'/bin','/usr/bin','/usr/local/bin'],
    cwd        => $www_dir,
    command    => '/usr/bin/npm install',
    creates    => "${www_dir}/node_modules",
    user       => 'root',
    require    => Class['nodejs'],
  }
  exec { 'bower_install' :
    path       => ["${venv}/bin",'/bin','/usr/bin','/usr/local/bin'],
    cwd        => $www_dir,
    command    => '/usr/bin/bower --allow-root install --config.interactive=false',
    creates    => "${www_dir}/bower_components",
    user       => 'root',
  }
  exec { 'gulp clean-build-app-prod':
    path       => ["${venv}/bin",'/bin','/usr/bin','/usr/local/bin'],
    cwd        => $www_dir,
    command    => 'gulp clean-build-app-prod',
    creates    => "${www_dir}/dist.prod",
    user       => 'root',
    require    => Exec['bower_install'],
  }
}
