#
# == Class: pwm::config
#
# Configure pwm
#
class pwm::config inherits pwm::params
{

    include ::tomcat::params

    # Allow pwm to write to the webapp directories it needs
    file { 'pwm-WEB-INF':
        ensure  => directory,
        name    => "${::tomcat::params::autodeploy_dir}/pwm/WEB-INF",
        owner   => $::tomcat::params::user,
        group   => $::tomcat::params::group,
        mode    => '0755',
        require => Class['pwm::install'],
    }

    file { 'pwm-logs':
        ensure  => directory,
        name    => "${::tomcat::params::autodeploy_dir}/pwm/WEB-INF/logs",
        owner   => $::tomcat::params::user,
        group   => $::tomcat::params::group,
        mode    => '0755',
        require => Class['pwm::install'],
    }

    file { 'pwm-LocalDB':
        ensure  => directory,
        name    => "${::tomcat::params::autodeploy_dir}/pwm/WEB-INF/LocalDB",
        owner   => $::tomcat::params::user,
        group   => $::tomcat::params::group,
        mode    => '0755',
        require => Class['pwm::install'],
    }

    # Pwm webapp configuration
    file { 'pwm-PwmConfiguration.xml':
        ensure  => present,
        name    => "${::tomcat::params::autodeploy_dir}/pwm/WEB-INF/PwmConfiguration.xml",
        source  => "puppet:///files/pwm-PwmConfiguration-${::fqdn}.xml",
        owner   => $::tomcat::params::user,
        group   => $::tomcat::params::group,
        mode    => '0644',
        require => Class['pwm::install'],
    }

    # Tomcat configuration
    include ::pwm::config::tomcat
}
