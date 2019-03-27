# ipset

#### Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)
3. [Reference](#reference)
4. [Limitations](#limitations)
5. [Changelog](#changelog)
6. [Development](#development)
7. [Thanks](#thanks)

## Overview

This module manages Linux IP sets.

* Checks for current ipset state, before doing any changes to it.
* Applies ipset every time it drifts from target state,
  not only on config file change.
* Handles type changes.
* Autostart support for RHEL 6 and RHEL 7 family (upstart, systemd).

## Usage

### Array

IP sets can be filled from an array data structure.
Typically passed from Hiera.

```puppet
ipset { 'foo':
  ensure => present,
  set    => ['1.2.3.4', '5.6.7.8'],
  type   => 'hash:ip',
}
```

### String

You can also pass a pre-formatted string directly, using one entry per line
(with ``\n`` as a separator).
This pattern is practical when generating the IP set entries using a template.

```puppet
ipset { 'foo':
  ensure => present,
  set    => "1.2.3.4\n5.6.7.8",
  type   => 'hash:ip',
}
```

### Module file

IP sets content can also be stored in a module file:

```puppet
ipset { 'foo':
  ensure => present,
  set    => "puppet:///modules/${module_name}/foo.ipset",
}
```

### Local file

Or using a plain text file stored on the filesystem:

```puppet
file { '/tmp/bar_set_content':
  ensure  => present,
  content => "1.2.3.0/24\n5.6.7.8/32"
}
-> ipset { 'bar':
  ensure => present,
  set    => 'file:///tmp/bar_set_content',
  type   => 'hash:net',
}
```

## Reference

* [Module reference](https://github.com/sl0m0ZA/puppet-ipset/blob/master/doc/reference.md)
* [ipset man page](https://linux.die.net/man/8/ipset)

## Limitations

* Tested on Debian and RedHat-like Linux distributions
* IPv6 sets have not been tested yet
* Only **hash** ipsets are supported (this excludes *bitmap* and *list:set*)

## Changelog

See [CHANGELOG](https://github.com/sl0m0ZA/puppet-ipset/blob/master/CHANGELOG.md)

## Development

See [development](https://github.com/sl0m0ZA/puppet-ipset/blob/master/doc/development.md)

## Thanks

This module is a fork of [pmuller/ipset](https://forge.puppet.com/pmuller/ipset),
which was forked from [mighq/ipset](https://github.com/mighq/puppet-ipset),
which was based on [thias/ipset](https://github.com/thias/puppet-ipset).
