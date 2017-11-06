# Class: tct::uwsgi
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
class tct::uwsgi (
  String $allowed_hosts = lookup('tct::allowed_hosts', String, 'first'),
  String $backend       = lookup('tct::backend', String, 'first'),
  String $basename      = lookup('tct::basename', String, 'first'),
  String $baseurl       = lookup('tct::baseurl', String, 'first'),
  String $db_host       = lookup('tct::db_host', String, 'first'),
  String $db_password   = lookup('tct::db_password', String, 'first'),
  String $db_user       = lookup('tct::db_user', String, 'first'),
  String $epubs_src_folder = lookup('tct::epubs_src_folder', String, 'first'),
  String $frontend      = lookup('tct::frontend', String, 'first'),
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

  # create directories for uwsgi
  file { '/run/uwsgi' :
    ensure => directory,
    owner  => $user,
    group  => 'nginx',
    mode   => '0775',
  }
  file { '/var/log/uwsgi' :
    ensure => directory,
    owner  => $user,
    group  => 'nginx',
    mode   => '0775',
  }
  file { '/var/log/uwsgi/nyu.log' :
    ensure => file,
    owner  => $user,
    group  => 'nginx',
    mode   => '0664',
  }

  # Install uwsgi
  python::pip { 'uwsgi':
    ensure     => latest,
    pkgname    => 'uwsgi',
    virtualenv => $venv,
    owner      => 'root',
    timeout    =>  1800,
  }

  # Load the uwsgi application config file
  #file { 'myapp.ini' :
  #  ensure  => file,
  #  owner   => $user,
  #  group   => 'nginx',
  #  path    => "${install_dir}/uwsgi/myapp.ini",  
  #  content => template('tct/myapp.ini.erb'),
  #}
  $uwsgi_ini = "enm_uwsgi.ini"
  file { $uwsgi_ini :
    ensure  => file,
    owner   => $user,
    group   => 'nginx',
    path    => "${install_dir}/${backend}/$uwsgi_ini",
    content => template('tct/enm_uwsgi.ini.erb'),
  }
  # Load the wsgi script
  #file { 'wsgi.py' :
  #  ensure  => file,
  #  path    => "${install_dir}/uwsgi/wsgi.py",
  #  content => template('tct/wsgi.py.erb'),
  #  require => File['myapp.ini'],
  #}
  file { '/etc/systemd/system/uwsgi.service' :
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content =>  template('tct/uwsgi.service.erb'),
  }
  service { 'uwsgi' :
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    provider   => 'systemd',
    require    => [ Python::Pip['uwsgi'], File['/etc/systemd/system/uwsgi.service'], File["$uwsgi_ini"], File['/var/log/uwsgi/nyu.log'], File['/run/uwsgi'], ], 
  }

}
