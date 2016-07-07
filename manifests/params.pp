class puppet::params {

	$puppetlabs_package='puppetlabs-release'


	#TODO: SuSE
	# zypper addrepo -f http://download.opensuse.org/repositories/systemsmanagement:/puppet/SLE_11_SP2/ puppet
	# zypper install puppet

	# exemple:
	# 8159919d6adc:/etc/profile.d # zypper addrepo -f http://download.opensuse.org/repositories/systemsmanagement:/puppet/SLE_11_SP2/ puppet
	# Adding repository 'puppet' [done]
	# Repository 'puppet' successfully added
	# Enabled: Yes
	# Autorefresh: Yes
	# GPG check: Yes
	# URI: http://download.opensuse.org/repositories/systemsmanagement:/puppet/SLE_11_SP2/
	#
	# 8159919d6adc:/etc/profile.d # zypper lr
	# # | Alias  | Name   | Enabled | Refresh
	# --+--------+--------+---------+--------
	# 1 | puppet | puppet | Yes     | Yes
	# 8159919d6adc:/etc/profile.d #


	case $::osfamily
	{
		'redhat':
		{
			$default_enable_puppetlabs_repo=true
			$enableepel=true
			$defaultsfile="/etc/sysconfig/puppet"
			$defaultstemplate="sysconfig.erb"
			$monitconfd="/etc/monit.d"
			$package_provider="rpm"

			#TODO: versio rh
			$puppet_master_packages=undef

			case $::operatingsystemrelease
			{
				/^6.*$/:
				{
					$puppetlabs_repo='https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm'
				}
				/^7.*$/:
				{
					$puppetlabs_repo='https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm'
				}
				default: { fail("Unsupported RHEL/CentOS version! - $::operatingsystemrelease")  }
			}
		}
		'Debian':
		{
			$default_enable_puppetlabs_repo=true
			case $::operatingsystem
			{
				'Ubuntu':
				{
					$enableepel=false
					$defaultsfile="/etc/default/puppet"
					$defaultstemplate="defaultsubuntu.erb"
					$monitconfd="/etc/monit/conf.d"
					$package_provider="dpkg"

					$puppet_master_packages = [ 'puppetmaster-passenger' ]

					case $::operatingsystemrelease
					{
						/^14.*$/:
						{
							$puppetlabs_repo='https://apt.puppetlabs.com/puppetlabs-release-trusty.deb'
						}
						default: { fail("Unsupported Ubuntu version! - $::operatingsystemrelease")  }
					}
				}
				'Debian': { fail("Unsupported")  }
				default: { fail("Unsupported Debian flavour!")  }
			}
		}
		default: { fail("Unsupported OS!")  }
	}
}
