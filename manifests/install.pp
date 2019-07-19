# Configure system to handle IP sets.
#
# @api private
#
class ipset::install {
  include ipset::params

  $cfg       = $::ipset::params::config_path
  $cfg_purge = $::ipset::params::config_purge
  
  # main package
  package { $::ipset::params::package:
    ensure => $::ipset::params::package_ensure,
    alias  => 'ipset',
  }

  # directory with config profiles (*.set & *.hdr files)
  file { $cfg:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    purge   => "${cfg_purge}",
    recurse => true,
  }

  # helper scripts
  ['sync', 'init'].each |$name| {
    file { "/usr/local/sbin/ipset_${name}":
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0754',
      source => "puppet:///modules/${module_name}/ipset_${name}",
    }
  }

  # configure autostart
  case $facts['os']['family'] {
    'RedHat': {
      case $facts['os']['release']['major'] {
        '6':     { include ipset::install::autostart_upstart }
        '7':     { include ipset::install::autostart_systemd }
        default: { warning('Autostart of ipset not implemented for this RedHat release.') }
      }
    }
    'Suse': {
      case $facts['os']['release']['major'] {
        '12':    { include ipset::install::autostart_systemd }
        '15':    { include ipset::install::autostart_systemd }
        default: { warning('Autostart of ipset not implemented for this Suse release.') }
      }
    }
    default: { warning('Autostart of ipset not implemented for this OS.') }
  }
}

# Configure upstart autostart
#
class ipset::install::autostart_upstart {
  include ipset::params
  $cfg = $::ipset::params::config_path

  # make sure libmnl is installed
  package { 'libmnl':
    ensure => installed,
    before => Package[$::ipset::params::package],
  }

  # do not use original RC start script from the ipset package
  # it is hard to define dependencies there
  # also, it can collide with what we define through puppet
  #
  # using exec instead of Service, because of bug:
  # https://tickets.puppetlabs.com/browse/PUP-6516
  exec { 'ipset_disable_distro':
    command => "/bin/bash -c '/etc/init.d/ipset stop && /sbin/chkconfig ipset off'",
    unless  => "/bin/bash -c '/sbin/chkconfig | /bin/grep ipset | /bin/grep -qv :on'",
    require => Package[$::ipset::params::package],
  }
  # upstart starter
  -> file { '/etc/init/ipset.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/init.upstart.erb"),
  }
  # upstart service autostart
  ~> service { 'ipset_enable_upstart':
    name     => 'ipset',
    enable   => true,
    provider => 'upstart',
  }
  # dependency is covered by running ipset before RC scripts suite, where firewall service is
}

# Configure systemd autostart
#
class ipset::install::autostart_systemd {
  include ipset::params
  $cfg = $::ipset::params::config_path

  # for management of dependencies
  $firewall_service = $::ipset::params::firewall_service

  # systemd service definition, there is no script in COS7
  file { '/usr/lib/systemd/system/ipset.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/init.systemd.erb"),
  }
  # systemd service autostart
  ~> service { 'ipset':
    ensure  => 'running',
    enable  => true,
    require => File['/usr/local/sbin/ipset_init'],
  }
}
