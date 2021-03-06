# Class: tct::nginx
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
class tct::nginx (
  String $allowed_hosts = lookup('tct::allowed_hosts', String, 'first'),
  String $backend       = lookup('tct::backend', String, 'first'),
  String $basename      = lookup('tct::basename', String, 'first'),
  String $baseurl       = lookup('tct::baseurl', String, 'first'),
  String $db_host       = lookup('tct::db_host', String, 'first'),
  String $db_password   = lookup('tct::db_password', String, 'first'),
  String $db_user       = lookup('tct::db_user', String, 'first'),
  String $media_root    = lookup('tct::media_root', String, 'first'),
  String $epubs_src_folder = lookup('tct::epubs_src_folder', String, 'first'),
  String $frontend      = lookup('tct::frontend', String, 'first'),
  String $install_dir   = lookup('tct::install_dir', String, 'first'),
  String $pub_src       = lookup('tct::pub_src', String, 'first'),
  String $secret_key    = lookup('tct::secret_key', String, 'first'),
  String $static_root   = lookup('tct::static_root', String, 'first'),
  String $tct_db        = lookup('tct::tct_db', String, 'first'),
  String $user          = lookup('tct::user', String, 'first'),
  String $venv          = lookup('tct::venv', String, 'first'),
  String $www_dir       = lookup('tct::www_dir', String, 'first'),
  #String $media         = lookup('tct::media', String, 'first'),
  #String $static        = lookup('tct::static', String, 'first'),
){

  include nginx
  nginx::resource::upstream { 'django' :
    ensure  => present,
    #members => [ 'unix:///tmp/nyu.sock', ],
    members => [ 'unix:///run/uwsgi/nyu.sock', ],
    #members => [ 'unix:///tmp/nyu.sock', ],
  }

  #file { 'uwsgi_params' :
  #  ensure  => file,
  #  owner   => 'nginx',
  #  group   => 'nginx',
  #  content => template('tct/uwsgi_params.erb'),
  #}

  nginx::resource::server { "$basename" :
     www_root => '/var/www/html/dist.prod',
  #  proxy        => 'http://localhost:54506',
  #  uwsgi   => 'unix:/run/uwsgi/tct.sock',
  #  uwsgi   => 'unix:/run/uwsgi/nyu.sock',
    listen_options => 'default_server',
    uwsgi          => 'django',
    uwsgi_params   => '/etc/nginx/uwsgi_params',
  }

  ##
  # media_root, epubs_src_folder, and static_root are created 
  # in inatall::backend. It's a bit confusing to leave it there, 
  # but that's where is is for now.
  ##
  file { "$static_root" :
    ensure  => directory,
    owner   => $user,
    group   => 'nginx',
    mode    => "0775",
    require => Class['nginx'],
  }

  #nginx::resource::location { '/media'  :
  #  location_alias => $media_root, 
  #  server         => $basename,
  #  require        => [ File[$media_root], File["$epubs_src_folder"], ],
  #}

  nginx::resource::location { '/static' :
    location_alias => $static_root, 
    server         => $basename,
    require        => File["$static_root"],
  }
  
  #
  # this actually needs to go to root, not /tct
  #
  #nginx::resource::location { '/tct' :
  #  location_alias => "/var/www/html/dist.prod", 
  #  server         => $basename,
  #}

  #nginx::resource::location { '/src' :
  #  location_alias => "/var/www/html/src", 
  #  server         => $basename,
  #}

  firewall { '100 allow http and https access' :
    dport  => [80, 443, 8080, 9000],
    proto  => tcp,
    action => accept,
  }

}
