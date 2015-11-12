class puppet::params {

	$puppetlabs_package='puppetlabs-release'
	$default_enable_puppetlabs_repo=true

	case $::osfamily
	{
		'redhat':
		{
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
