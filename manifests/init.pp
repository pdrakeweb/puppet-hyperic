# Class: hyperic
#
# This module manages hyperic
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class hyperic ($hyperic_version = "4.5") {

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
