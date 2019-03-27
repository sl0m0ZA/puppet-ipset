# Declare an IP Set.
#
# @param set IP set content or source.
# @param ensure Should the IP set be created or removed ?
# @param type Type of IP set.
# @param options IP set options.
# @param ignore_contents If ``true``, only the IP set declaration will be
#   managed, but not its content.
# @param keep_in_sync If ``true``, Puppet will update the IP set in the kernel
#   memory. If ``false``, it will only update the IP sets on the filesystem.
#
# @example An IP set containing individual IP addresses, specified in the code.
#   ipset { 'a-few-ip-addresses':
#     set => ['10.0.0.1', '10.0.0.2', '10.0.0.42'],
#   }
#
# @example An IP set containing IP networks, specified with Hiera.
#   ipset { 'hiera-networks':
#     set  => lookup('foo', IP::Address::V4::CIDR),
#     type => 'hash:net',
#   }
#
# @example An IP set of IP addresses, based on a file stored in a module.
#   ipset { 'from-puppet-module':
#     set => "puppet:///modules/${module_name}/ip-addresses",
#   }
#
# @example An IP set of IP networks, based on a file stored on the filesystem.
#   ipset { 'from-filesystem':
#     set => 'file:///path/to/ip-addresses',
#   }
#
define ipset (
  IPSet::Set $set,
  Enum['present', 'absent'] $ensure = 'present',
  IPSet::Type $type = 'hash:ip',
  IPSet::Options $options = {},
  # do not touch what is inside the set, just its header (properties)
  Boolean $ignore_contents = false,
  # keep definition file and in-kernel runtime state in sync
  Boolean $keep_in_sync = true,
) {
  include ipset::params

  contain ipset::install

  $default_options = {
    'family'   => 'inet',
    'hashsize' => '1024',
    'maxelem'  => '65536',
  }

  $actual_options = merge($default_options, $options)

  if $ensure == 'present' {
    # assert "present" target

    $opt_string = inline_template('<%= (@actual_options.sort.map { |k,v| k.to_s + " " + v.to_s }).join(" ") %>')

    # header
    file { "${::ipset::params::config_path}/${title}.hdr":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => "create ${title} ${type} ${opt_string}\n",
      notify  => Exec["sync_ipset_${title}"],
    }

    # content
    case $set {
      IPSet::Set::Array: {
        # create file with ipset, one record per line
        file { "${::ipset::params::config_path}/${title}.set":
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0640',
          content => inline_template('<%= (@set.map { |i| i.to_s }).join("\n") %>'),
        }
      }
      IPSet::Set::Puppet_URL: {
        # passed as puppet file
        file { "${::ipset::params::config_path}/${title}.set":
          ensure => file,
          owner  => 'root',
          group  => 'root',
           mode  => '0640',
          source => $set,
        }
      }
      IPSet::Set::File_URL: {
        # passed as target node file
        file { "${::ipset::params::config_path}/${title}.set":
          ensure => file,
          owner  => 'root',
          group  => 'root',
          mode   => '0640',
          source => regsubst($set, '^.{7}', ''),
        }
      }
      String: {
        # passed directly as content string (from template for example)
        file { "${::ipset::params::config_path}/${title}.set":
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0640',
          content => $set,
        }
      }
      default: {
        fail('Typing prevent reaching this branch')
      }
    }

    # add switch to script, if we 
    if $ignore_contents {
      $ignore_contents_opt = ' -n'
    } else {
      $ignore_contents_opt = ''
    }

    # sync if needed by helper script
    exec { "sync_ipset_${title}":
      path    => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],

      # use helper script to do the sync
      command => "/usr/local/sbin/ipset_sync -c '${::ipset::params::config_path}'    -i ${title}${ignore_contents_opt}",

      # only when difference with in-kernel set is detected
      unless  => "/usr/local/sbin/ipset_sync -c '${::ipset::params::config_path}' -d -i ${title}${ignore_contents_opt}",

      require => Package['ipset'],
    }

    if $keep_in_sync {
      File["${::ipset::params::config_path}/${title}.set"] ~> Exec["sync_ipset_${title}"]
    }
  } elsif $ensure == 'absent' {
    # ensuring absence

    # do not contain config files
    file { ["${::ipset::params::config_path}/${title}.set", "${::ipset::params::config_path}/${title}.hdr"]:
      ensure  => absent,
    }

    # clear ipset from kernel
    exec { "ipset destroy ${title}":
      path    => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],

      command => "/usr/sbin/ipset destroy ${title}",
      onlyif  => "/usr/sbin/ipset list -name ${title} &>/dev/null",

      require => Package['ipset'],
    }
  } else {
    fail('Typing prevent reaching this branch')
  }
}
