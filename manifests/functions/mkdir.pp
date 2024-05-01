# Function: nfs::functions::mkdir
#
# This Function exists to
#  1. manage dir creation
#
# Parameters
#
# @param ensure
#   Sets the ensure parameter of the directory, inherited from other classes invoking this defined resource type
#
# Examples
#
# This Function should not be called directly.
#
# Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# Authors
#
# * Daniel Klockenkaemper <mailto:dk@marketing-factory.de>
#
define nfs::functions::mkdir (
  String $ensure = 'present',
) {
  if $ensure != 'absent' {
    exec { "mkdir_recurse_${name}":
      path    => ['/bin', '/usr/bin'],
      command => "mkdir -p ${name}",
      unless  => "test -d ${name}",
    }
  }
}
