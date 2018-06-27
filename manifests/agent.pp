class puppet::client(
                      $puppetmaster          = 'puppetmaster',
                      $puppetmasterport      = '8140',
                      $pluginsync            = true,
                      $waitforcert           = 30,
                      $showdiff              = true,
                      $ensure                = 'installed',
                      $daemon_status         = 'running',
                      $service_enable        = true,
                      $srcdir                = '/usr/local/src',
                      $manage_package        = $puppet::params::manage_package_default,
                      $log                   = '/var/log/puppet/puppet.log',
                      $logdir                = '/var/log/puppet',
                      $logrotate_rotate      = '15',
                      $logrotate_maxsize     = '100M',
                      $install_nagios_checks = true,
                      $nagios_check_basedir  = '/usr/local/bin',
                    ) inherits puppet::params {

  include ::puppet

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($manage_package)
  {
    if($puppet::params::puppet_install_supported==false)
    {
      fail("Installation unsupported on ${::operatingsystem} ${::operatingsystemrelease}")
    }

    package { 'puppet':
      ensure => $ensure,
      before => Exec['mkdir_logpuppet'],
      #require => Class['puppet::puppetlabsrepo'],
    }

    if($puppet::puppetlabsrepo::enable_puppetlabs_repo)
    {
      Package['puppet'] {
        require => Class['puppet::puppetlabsrepo'],
      }
    }
  }

  file { $puppet::params::defaultsfile:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Exec['mkdir_logpuppet'],
    notify  => Service['puppet'],
    before  => Service['puppet'],
    content => template("${module_name}/${puppet::params::defaultstemplate}"),
  }

  exec { 'mkdir_logpuppet':
    command => '/bin/mkdir -p /var/log/puppet',
    creates => '/var/log/puppet',
  }

  concat::fragment{ 'puppetconf agent':
    target  => $puppet::params::puppetconf,
    order   => '01',
    content => template("${module_name}/puppetconf_agent.erb"),
    before  => Service['puppet'],
    notify  => Service['puppet'],
  }

  service { 'puppet':
    ensure  => $daemon_status,
    enable  => $service_enable,
    require => Class['puppet'],
  }

  if($autorestart) and ($daemon_status=='running')
  {
    if(defined(Class['monit']))
    {
      monit::checkpid { 'puppetd':
        pid        => '/var/run/puppet/agent.pid',
        initscript => '/etc/init.d/puppet',
      }
    }
  }





}
