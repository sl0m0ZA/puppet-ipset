# Module parameters.
#
# @param use_firewall_service Define the firewall service used by the server.
#   Defaults to the Linux distribution default.
class ipset::params (
  Optional[Enum['iptables', 'firewalld', 'SuSEfirewall2_init']] $use_firewall_service = undef,
  Enum['latest','present'] $package_ensure = 'latest',
  Optional[Enum['true', 'false']] $config_purge_set = undef,
) {
  $package = $facts['os']['family'] ? {
    'RedHat' => 'ipset',
    'Suse'   => 'ipset',
    default  => 'ipset',
  }

  $config_path = $facts['os']['family'] ? {
    'RedHat' => '/etc/sysconfig/ipset.d',
    'Debian' => '/etc/ipset.d',
    'Suse'   => '/etc/ipset.d',
    default  => '/etc/ipset.d',
  }

  if $config_purge_set {
    $config_purge = $config_purge_set
  } else {
    $config_purge = true
  }
      
  if $use_firewall_service {
    # use specified override
    $firewall_service = $use_firewall_service
  } else {
    # use os firewall service
    case $facts['os']['family'] {
      'RedHat': {
        $firewall_service = $facts['os']['release']['major'] ? {
          '6'     => 'iptables',
          '7'     => 'firewalld',
          default => 'iptables',
        }
      }
      'Suse': {
        $firewall_service = $facts['os']['release']['major'] ? {
          '12'    => 'SuSEfirewall2_init',
          '15'    => 'firewalld',
          default => 'iptables',
        }
      }
      default: {
        # by default expect everyone to use iptables
        $firewall_service = 'iptables'
      }
    }
  }
}
