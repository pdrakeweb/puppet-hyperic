# Class: hyperic
#
# This module manages hyperic
#
# Parameters:
#
# Actions:
#
# Requires: java heira
#
# Sample Usage: include hyperic::agent
#
class hyperic ($hyperic_version = "4.5.3") {

  include java

  group { "hyperic":
     ensure   => present,
  }
  
  user { "hyperic":
     ensure      => present,
     gid         => "hyperic",
     comment     => "Hyperic",
     home        => "/home/hyperic",
     shell       => "/bin/false",
     managehome  => true,
     membership  => "minimum",
  }
}
