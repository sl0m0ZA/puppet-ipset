# Changelog

## 0.6.2 (2019-03-27)
 
* Incorporated suggested changes from pmuller contributors listed below
* ipset version can be pinned via params
* Dependancy on thrnio/ip removed as puppet includes it in stdlib
* Added rest of hash types
* Documented support for Debian/Ubuntu OS as tested

## 0.6.1 (2019-03-27)

* Forked from pmuller/ipset
* Added "purge" option to params
* Made read-write permissions stricter on config directory (0640)

## 0.6.0 (2018-03-13)

* Support Puppet 4 and Puppet 5
* Tested release
* Improved documentation

## 0.5.2 (2016-12-02)

* installation tuning

## 0.5.1 (2016-07-22)

* just code quality fixes

## 0.5.0 (2016-07-19)

* improved support for rhel 7 + service deps
* fix from pull request #10 & #13
* be more strict what we accept as params
* fix: actually do the removal
* if loading of set contents fail, fail puppet
* ipset::unmanaged support

## 0.4.1 (2016-06-16)

* fix lost return value in ipset_sync

## 0.4.0 (2016-05-27)

* do not collide with sysvinit service from pkg

## 0.3.3 (2016-04-14)

* whitespace cleanup - indentation

## 0.3.2 (2016-04-14)

* verbose output option
* trim whitespaces from start&end of config file when comparing

## 0.3.1 (2016-02-26)

* /32 and /128 entries fix

## 0.3.0 (2016-02-26)

* support for passing set content as an array
* using swap when changing set contents - solves iptables cooperation problems
* ability to not sync the runtime (in-kernel) state with configs
* ability to change only one of set options
* input cleanup for duplicates in set content
* better performance when checking for set existence
* config folder for debian changed to /etc/ipset.d
* other minor code & bug fixes

## 0.2.1 (2015-04-26)

* documentation update

## 0.2.0 (2015-04-26)

* code quality tuning
* usage examples added to README.md
* systemd service definition / centos7 support

## 0.1.0 (2015-01-23)

* initial module release
