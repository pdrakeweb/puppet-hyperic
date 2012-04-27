class hyperic::client inherits hyperic {

  $hyperic_agent_source = "hyperic-hq-agent-${hyperic_version}-${architecture}-${kernel}.tar.gz"
  $hyperic_server_ip = hiera("hyperic_server_ip", "127.0.0.1")

  file { "/home/hyperic/src/hyperic-hq-agent.tar.gz":
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///modules/hyperic/${hyperic_agent_source}",
    notify  => 'hyperic-agent-install',
  }

  file { "/etc/init.d/hyperic-agent":
    owner   => root,
    group   => root,
    mode    => 755,
    source  => "puppet:///modules/hyperic/hq-agent",
  }

  file { "/etc/default/hyperic-agent":
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("hyperic/hyperic-agent.default.erb"),
  }

  exec { "hyperic-agent-install":
    path    => "/bin:/usr/bin:/usr/local/bin",
    cwd     => "/home/hyperic/src",
    command => "tar -xzf hyperic-hq-agent.tar.gz",
    require => File["/home/hyperic/src/hyperic-hq-agent.tar.gz"],
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
    require   => File["/etc/init.d/hyperic-agent"],
  }
}