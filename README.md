# ipset

[![Build Status](https://travis-ci.org/pmuller/puppet-ipset.svg)](https://travis-ci.org/pmuller/puppet-ipset)

## Overview

Linux ipset management by puppet.

Roughly based on [thias/ipset](https://github.com/thias/puppet-ipset) module.
* checks for current ipset state, before doing any changes to it
* applies ipset every time it drifts from target state, not only on config file change
* handles type changes
* autostart support for rhel-6 and rhel-7 family (upstart, systemd)

## Usage

### direct content

Resource accepts ipset content as list of entries, one entry per line ("\n" separated).
Can be generated by ERB template, or filled in directly from the manifest.

    ipset { 'foo':
      ensure => present,
      set    => "1.2.3.4\n5.6.7.8",
      type   => 'hash:ip',
    }

### content as array

Set can be filled from array data structure. Typically passed from Hiera.

    ipset { 'foo':
      ensure => present,
      set    => ['1.2.3.4', '5.6.7.8'],
      type   => 'hash:ip',
    }

### local file

Set will be filled in from the file present on the target computer's filesystem.

    file { '/tmp/bar_set_content':
      ensure  => present,
      content => "1.2.3.0/24\n5.6.7.8/32"
    }
    ->
    ipset { 'bar':
      ensure => present,
      set    => 'file:///tmp/bar_set_content',
      type   => 'hash:net',
    }

### puppet master file

Content is passed from the file available in puppet master's definitions.

    ipset { 'baz':
      ensure => present,
      set    => 'puppet:///modules/foo/bar.ipset',
    }
