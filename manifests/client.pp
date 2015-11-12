class puppet::client(
											$puppetmaster= 'puppetmaster',
											$puppetmasterport='8140',
											$pluginsync=true,
											$waitforcert=30,
											$showdiff=true,
											$ensure='installed',
											$daemon_status='running',
											$autorestart=true,
											$report=true,
											$srcdir='/usr/local/src',
										) inherits puppet::params {

	validate_bool($pluginsync)
	validate_bool($autorestart)

	validate_re($ensure, [ '^installed$', '^latest$' ], "Not a valid package status: ${ensure}")
	validate_re($daemon_status, [ '^running$', '^stopped$' ], "Not a valid daemon status: ${ensure}")

	Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

	package { 'puppet':
		ensure  => $ensure,
		require => Class['puppet::puppetlabsrepo'],
	}

	file { $defaultsfile:
		ensure  => present,
		owner   => "root",
		group   => "root",
		mode    => 0644,
		require => Exec['mkdir_logpuppet'],
		notify  => Service["puppet"],
		before  => Service["puppet"],
		content => template("${module_name}/${defaultstemplate}"),
	}

	exec { 'mkdir_logpuppet':
		command => '/bin/mkdir -p /var/log/puppet',
		creates => '/var/log/puppet',
		require => Package['puppet'],
	}

	concat::fragment{ 'puppetconf agent':
		target  => '/etc/puppet/puppet.conf',
		order   => '01',
		content => template("${module_name}/puppetconf_agent.erb"),
		before  => Service['puppet'],
		notify  => Service['puppet'],
	}

	service { 'puppet':
		enable => true,
		ensure => $daemon_status,
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
