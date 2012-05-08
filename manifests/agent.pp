class hyperic::agent inherits hyperic {

  $hyperic_agent_source = hiera("hyperic_agent_source", "http://sourceforge.net/projects/hyperic-hq/files/Hyperic%204.5.3/Hyperic%204.5.3-GA/hyperic-hq-agent-4.5.3-x86-64-linux.tar.gz/download")
  $hyperic_server_ip = hiera("hyperic_server_ip", "127.0.0.1")
  $hyperic_hq_user = hiera("hyperic_hq_user", "hqadmin")
  $hyperic_hq_pass = hiera("hyperic_hq_pass", "hqadmin")

  file { "/home/hyperic/src":
    owner   => hyperic,
    group   => admin,
    mode    => 755,
    ensure  => directory,
    require => User["hyperic"],
  }

  exec { "download-hyperic-agent":
    path        => "/bin:/usr/bin:/usr/local/bin",
    cwd         => "/home/hyperic/src",
    command     => "wget ${hyperic_agent_source} -O hyperic-hq-agent-${hyperic_version}.tar.gz",
    creates => "/home/hyperic/src/hyperic-hq-agent-${hyperic_version}.tar.gz",
    notify  => Exec["hyperic-agent-install"],
    require => File["/home/hyperic/src"],
  }

  file { "/etc/init.d/hyperic-agent":
    owner   => root,
    group   => root,
    mode    => 755,
    source  => "puppet:///modules/hyperic/hyperic-agent",
  }

  file { "/etc/default/hyperic-agent":
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("hyperic/hyperic-agent.default.erb"),
  }

  exec { "hyperic-agent-install":
    path        => "/bin:/usr/bin:/usr/local/bin",
    cwd         => "/home/hyperic/src",
    command     => "tar -xzf hyperic-hq-agent-${hyperic_version}.tar.gz && chown -R hyperic:admin /home/hyperic/src/hyperic-hq-agent-${hyperic_version}",
    require     => Exec["download-hyperic-agent"],
    refreshonly => true,
  }
  
  file { "/home/hyperic/src/hyperic-hq-agent-${hyperic_version}/conf/agent.properties":
    owner       => hyperic,
    group       => hyperic,
    mode        => 644,
    content     => template("hyperic/agent.properties.erb"),
    require     => Exec["hyperic-agent-install"],
  }
  
  service { "hyperic-agent":
    ensure    => running,
    hasstatus => false,
    require   => [ File["/etc/init.d/hyperic-agent"], File["/home/hyperic/src/hyperic-hq-agent-${hyperic_version}/conf/agent.properties"] ],
  }
}

class hyperic::agent::mongodb inherits hyperic::agent {

  exec { "hyperic-agent-mongodb":
    path    => "/bin:/usr/bin:/usr/local/bin",
    cwd     => "/home/hyperic/src/hyperic-hq-agent-${hyperic_version}/bundles/agent-${hyperic_version}/pdk/plugins",
    command => "wget --no-check-certificate https://raw.github.com/pdrakeweb/hyperic-mongodb/master/mongodb-plugin.xml && chown hyperic:hyperic mongodb-plugin.xml",
    creates => "/home/hyperic/src/hyperic-hq-agent-${hyperic_version}/bundles/agent-${hyperic_version}/pdk/plugins/mongodb-plugin.xml",
    notify  => Service["hyperic-agent"],
    require => [ Service["mongodb"], Exec["hyperic-agent-install"] ],
  }

}

class hyperic::agent::nginx inherits hyperic::agent {

  exec { "hyperic-agent-nginx":
    path    => "/bin:/usr/bin:/usr/local/bin",
    cwd     => "/home/hyperic/src/hyperic-hq-agent-${hyperic_version}/bundles/agent-${hyperic_version}/pdk/plugins",
    command => "wget http://nginx-hyperic.googlecode.com/svn/trunk/nginx-plugin.xml && chown hyperic:hyperic nginx-plugin.xml",
    creates => "/home/hyperic/src/hyperic-hq-agent-${hyperic_version}/bundles/agent-${hyperic_version}/pdk/plugins/nginx-plugin.xml",
    notify  => Service["hyperic-agent"],
    require => [ Service["nginx"], Exec["hyperic-agent-install"] ],
  }

}

class hyperic::agent::varnish inherits hyperic::agent {

  package { "libconfig-ini-simple-perl":
    ensure  => installed,
  }

  file { "/home/hyperic/src/hyperic-hq-agent-${hyperic_version}/bundles/agent-${hyperic_version}/pdk/plugins/varnish-plugin.xml":
    owner       => hyperic,
    group       => hyperic,
    mode        => 644,
    source      => "puppet:///modules/hyperic/varnish-plugin.xml",
    notify      => Service["hyperic-agent"],
    require     => [ Service["varnish"], Exec["hyperic-agent-install"] ],
  }

  file { "/home/hyperic/varnishstat.pl":
    owner       => root,
    group       => root,
    mode        => 755,
    source      => "puppet:///modules/hyperic/varnishstat.pl",
    require     => Package["libconfig-ini-simple-perl"],
  }

}

class hyperic::agent::puppet-agent inherits hyperic::agent {

  file { "/home/hyperic/src/hyperic-hq-agent-${hyperic_version}/bundles/agent-${hyperic_version}/pdk/plugins/puppet-agent-plugin.xml":
    owner       => hyperic,
    group       => hyperic,
    mode        => 644,
    source      => "puppet:///modules/hyperic/puppet-agent-plugin.xml",
    notify      => Service["hyperic-agent"],
    require     => [ Service["puppet"], Exec["hyperic-agent-install"] ],
  }

}
