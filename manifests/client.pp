# == Class: nfs::client
#
# This class exists to
#  1. order the loading of classes
#  2. including all needed classes for nfs as a client
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# * Daniel Klockenkaemper <mailto:dk@marketing-factory.de>
#
class nfs::client (
  String $ensure              = $nfs::ensure,
  String $nfs_v4              = $nfs::nfs_v4_client,
  String $nfs_v4_mount_root   = $nfs::nfs_v4_mount_root,
  String $nfs_v4_idmap_domain = $nfs::nfs_v4_idmap_domain,
) {
  # TODO: 'anchor' may be an outdated/incorrect means of handling resource ordering, look into changing this to 'contain' with Class calls?
  #   Related: https://blog.mayflower.de/4573-The-Puppet-Anchor-Pattern-in-Practice.html
  anchor { 'nfs::client::begin': }
  anchor { 'nfs::client::end': }

  # package(s)
  class { 'nfs::client::package': }

  # configuration
  class { 'nfs::client::config': }

  # service(s)
  class { 'nfs::client::service': }

  if $ensure == 'present' {
    # we need the software before configuring it
    Anchor['nfs::client::begin']
    -> Class['nfs::client::package']
    -> Class['nfs::client::config']
    # we need the software and a working configuration before running a service
    Class['nfs::client::package'] -> Class['nfs::client::service']
    Class['nfs::client::config']  -> Class['nfs::client::service']
    Class['nfs::client::service'] -> Anchor['nfs::client::end']
  } else {
    # make sure all services are getting stopped before software removal
    Anchor['nfs::client::begin']
    -> Class['nfs::client::service']
    -> Class['nfs::client::package']
    -> Anchor['nfs::client::end']
  }
}
