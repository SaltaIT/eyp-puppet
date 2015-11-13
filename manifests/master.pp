class puppet::master(
                      $certname,
                      $dns_alt_names=undef,
                      $puppetmasterport='8140',
                      $report_to_logstash=true,
                      $manage_apache=true,
                      $masterhttplog='/dev/null',
                      $autosign=true,
                      $pluginsync=true,
                      $errorlog='/dev/null',
                      $combinedlog='/dev/null',
                      $ca_ttl='1000y',
                      $logstash_host='127.0.0.1',
                      $logstash_port='5959',
                      $report=true,
                    ) inherits puppet::params {

  #masterless only

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  case $::osfamily
	{
		'redhat':
		{
      fail('TODO')
    }
  }

  package { $puppet::params::puppet_master_packages:
    ensure  => 'installed',
    require => Class['puppet::puppetlabsrepo'],
  }

  #require puppet::puppetlabsrepo

  file { '/etc/default/puppetmaster':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/master/debian/puppetmaster.erb"),
    require => Package[$puppet::params::puppet_master_packages],
    notify  => Service['apache2'],
  }

  concat::fragment{ 'puppetconf master':
    target  => '/etc/puppet/puppet.conf',
    order   => '02',
    content => template("${module_name}/puppetconf_master.erb"),
    require => Package[$puppet::params::puppet_master_packages],
    notify  => Service['apache2'],
  }

  # /etc/apache2/sites-available/puppetmaster.conf
  file { '/etc/apache2/sites-available/puppetmaster.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/master/apache/vhost_puppetmaster.erb"),
    require => Package[$puppet::params::puppet_master_packages],
    notify  => Service['apache2'],
  }

  exec { "build CA $certname":
    command => "puppet cert --generate ${certname}",
    creates => "/var/lib/puppet/ssl/certs/${certname}.pem",
    require => Package[$puppet::params::puppet_master_packages],
  }

  file { '/etc/apache2/sites-enabled/puppetmaster.conf':
    ensure  => '/etc/apache2/sites-available/puppetmaster.conf',
    require => File['/etc/apache2/sites-available/puppetmaster.conf'],
    notify  => Service['apache2'],
  }

  file { '/etc/puppet/logstash.yaml':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template("${module_name}/logstash_reporter/logstash.yaml.erb"),
  }

  service { 'apache2':
    ensure => 'running',
    enable => true,
    require =>  [
                  File[
                        [
                          '/etc/apache2/sites-enabled/puppetmaster.conf',
                          '/etc/apache2/sites-available/puppetmaster.conf',
                          '/etc/default/puppetmaster',
                          '/etc/puppet/logstash.yaml'
                        ]
                      ],
                  Exec["build CA $certname"],
                  Concat['/etc/puppet/puppet.conf'],
                ],
  }
}
