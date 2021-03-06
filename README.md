# pwm

A Puppet module for managing Pwm, "Open Source Password Self Service for LDAP 
directories". This version is only tested with Pwm 1.8

# Module usage

The puppet manifest, [pwm.pp](vagrant/pwm.pp) gives an idea on how to use this 
module. For details please refer to documentation in the [main 
class](manifests/init.pp).

# Testing with Vagrant

This module comes with Vagrant support. Two VMs are included:

* *pwm-dirsrv*: 389 Directory Server instance running on CentOS 7
* *pwm*: Pwm 1.8 instance running on Ubuntu 16.04

All passwords for the directory server, pwm and directory users are set to
"vagrant".

When using Vagrant Pwm is built from sources which takes a bit of time when
bringing up the VM the first time.

To ensure that you can access all the services on *pwm-dirsrv* and *pwm* add
these lines to /etc/hosts or equivalent:

    192.168.103.100 pwm.local pwm
    192.168.103.101 pwm-dirsrv.local pwm-dirsrv

In particular 389-console depends on these being set - it is not easy to get it 
to play nicely with port forwards.

Once these are in place you can access Pwm using a web browser at
http://pwm.local:8080/pwm.

To login with 389-console use https://pwm-dirsrv.local:9830 as the URL. The 
console should ask if you want to accept the admin server certificate. If you 
say yes, you will be able to modify the directory.

When *pwm-dirsrv* is provisioned several things happen:

* The memberOf plugin is enabled and configured
* TLS is enabled for the slapd instance and the admin server
* A minimal sample directory tailored for Pwm is imported

The Directory server instance is called "vagrant". You can manage it with
systemctl like this:

    $ systemctl status dirsrv@vagrant

The provided sample directory contains several test users:

* uid=john.doe,ou=People,dc=example,dc=org (a normal user)
* uid=jane.doe,ou=People,dc=example,dc=org (a Pwm test user)
* uid=ken,ou=People,dc=example,dc=org (a Pwm administrator)
* uid=pwmproxy,ou=People,dc=example,dc=org (Pwm proxy user)

Pwm uses the "cn" attribute for user logins. Its value matches that of the
"uid". ACLs have been set so that Pwm can operate normally.

When 389 Directory server is deployed the directory administrator,
cn=Directory Administrator, is created automatically. This user is primarily
useful for modifying directory configuration and for making test LDAP searches.
The Directory Server can also be managed using 389-console. Login as "admin"
with password "vagrant".

The pwm instance should work out of the box as a simple PwmConfiguration.xml is 
provided. Try logging in as "john.doe" with password "vagrant" to verify that.

# Debugging tips for Directory Server

Verifying that Pwm proxy user can list users in the "Pwm administrators" group:

    $ ldapsearch -D"uid=pwmproxy,ou=People,dc=example,dc=org" -W -p 389 -h localhost -x -b 'dc=example,dc=org' 'cn=Pwm Administrators'

Export the database as LDIF:

    $ cd /var/lib/dirsrv/slapd-vagrant/bak
    $ db2ldif -Z vagrant -s 'dc=example,dc=org' -a vagrant.ldif

Check a configuration setting:

    $ ldapsearch -D"cn=Directory Manager" -W -p 389 -h localhost -x -b 'cn=config' 'cn=MemberOf Plugin'

For further samples check [vagrant/prepare-directory.sh](vagrant/prepare-directory.sh).

Note that if your production LDAP directory contains a large number of user objects
you may need to set nsslapd-lookthroughlimit to -1 for the Pwm proxy user.

# Using Vagrant scripts to enable TLS on production servers

The [vagrant](vagrant) subdirectory contains several scripts for automatically 
enabling TLS and memberOf plugin in Directory Server and Admin Server. These can 
also be used on a production server by modifying [vagrant/vars](vagrant/vars) 
and [vagrant/console-dirsrv.ldif](vagrant/console-dirsrv.ldif) to match the 
production setup.
