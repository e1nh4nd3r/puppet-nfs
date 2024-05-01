# Function: nfs::client::mount
# TODO: Figure out how to make this match the defined resource type name below and make pdk less sad.
# TODO: Add datatypes to class parameter documentation
# TODO: Add examples to class parameter documentation
# TODO: Move Examples in this file to README.md under Usage (or something)
#
# This defined type exists to manage all mounts on a nfs client
#
# @param server
#   Sets the ip address of the server with the nfs export
#
# @param share
#   Sets the name of the nfs share on the server
#
# @param ensure
#   Sets the ensure parameter of the mount
#
# @param remounts
#   Sets the remounts parameter of the mount
#
# @param atboot
#   Sets the atboot parameter of the mount.
#
# @param options_nfsv4
#   Sets the mount options for a nfs version 4 mount.
#
# @param options_nfs
#   Sets the mount options for a nfs mount.
#
# @param bindmount
#   When not 'undef' it will create a bindmount on the node
#   for the nfs mount.
#
# @param nfstag
#   Sets the nfstag parameter of the mount.
#
# @param nfs_v4
#   Boolean. When set to true, it uses nfs version 4 to mount a share.
#
# @param owner
#   Set owner of mount dir
#
# @param group
#   Set group of mount dir
#
# @param mode
#   Set mode of mount dir
#
# @param mount_root
#   Overwrite mount root if differs from server config
#
# === Examples
#
# class { '::nfs':
#   client_enabled => true,
#   nfs_v4_client  => true
# }
#
# nfs::client::mount { '/target/directory':
#   server        => '1.2.3.4',
#   share         => 'share_name_on_nfs_server',
#   remounts      => true,
#   atboot        => true,
#   options_nfsv4 => 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
# }
#
# === Authors
#
# * Daniel Klockenkaemper <mailto:dk@marketing-factory.de>
#
define nfs::client::mount (
  String $server,
  String $share           = undef,
  String $ensure          = 'mounted',
  String $mount           = $title,
  Boolean $remounts       = false,
  Boolean $atboot         = false,
  String $options_nfsv4   = $nfs::client_nfsv4_options,
  String $options_nfs     = $nfs::client_nfs_options,
  String $bindmount       = undef,
  String $nfstag          = undef,
  String $nfs_v4          = $nfs::client::nfs_v4,
  String $owner           = undef,
  String $group           = undef,
  String $mode            = undef,
  String $mount_root      = undef,
  String $manage_packages = $nfs::manage_packages,
  String $client_packages = $nfs::effective_client_packages,
) {
  if $manage_packages and $client_packages != undef {
    $mount_require = [Nfs::Functions::Mkdir[$mount], Package[$client_packages]]
  } else {
    $mount_require = [Nfs::Functions::Mkdir[$mount]]
  }

  if $nfs_v4 == true {
    if $mount_root == undef {
      $root = ''
    } else {
      $root = $mount_root
    }

    if $share != undef {
      $sharename = "${root}/${share}"
    } else {
      $sharename = regsubst($mount, '.*(/.*)', '\1')
    }

    nfs::functions::mkdir { $mount:
      ensure => $ensure,
    }

    mount { "shared ${sharename} by ${server} on ${mount}":
      ensure   => $ensure,
      device   => "${server}:${sharename}",
      fstype   => $nfs::client_nfsv4_fstype,
      name     => $mount,
      options  => $options_nfsv4,
      remounts => $remounts,
      atboot   => $atboot,
      require  => $mount_require,
    }

    if $bindmount != undef {
      nfs::functions::bindmount { $mount:
        ensure     => $ensure,
        mount_name => $bindmount,
      }
    }
  } else {
    if $share != undef {
      $sharename = $share
    } else {
      $sharename = $mount
    }

    nfs::functions::mkdir { $mount:
      ensure => $ensure,
    }
    mount { "shared ${sharename} by ${server} on ${mount}":
      ensure   => $ensure,
      device   => "${server}:${sharename}",
      fstype   => $nfs::client_nfs_fstype,
      name     => $mount,
      options  => $options_nfs,
      remounts => $remounts,
      atboot   => $atboot,
      require  => $mount_require,
    }
  }

  if $owner != undef or $group != undef or $mode != undef {
    file { $mount:
      ensure  => $ensure == absent ? { true => 'absent', default => 'directory' },
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      force   => true,
      require => Mount["shared ${sharename} by ${server} on ${mount}"],
    }
  }
}
