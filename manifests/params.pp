# Module parameters.
#
# @param use_firewall_service Define the firewall service used by the server.
#   Defaults to the Linux distribution default.
class ipset::params (
  Optional[Enum['iptables', 'firewalld']] $use_firewall_service = undef,
  Enum['latest','present'] $package_ensure = 'latest',
  Optional[Enum['true', 'false']] $config_purge_set = undef,
) {
  $package = $facts['os']['family'] ? {
    'RedHat' => 'ipset',
    default  => 'ipset',
  }

  $config_path = $facts['os']['family'] ? {
    'RedHat' => '/etc/sysconfig/ipset.d',
    'Debian' => '/etc/ipset.d',
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
    # OS defaults
    if $facts['os']['family'] == 'RedHat' {
      if  $facts['os']['release']['major'] == '6' {
        $firewall_service = 'iptables'
      } elsif $facts['os']['release']['major'] == '7' {
        $firewall_service = 'firewalld'
      }
    } else {
      # by default expect everyone to use iptables
      $firewall_service = 'iptables'
    }
  }
}
