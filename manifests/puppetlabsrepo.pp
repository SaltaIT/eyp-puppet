class puppet::puppetlabsrepo(
                              $enable_puppetlabs_repo = true,
                              $srcdir                 = '/usr/local/src',
                            ) inherits puppet::params {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($enable_puppetlabs_repo)
  {
    if($puppet::params::puppetlabs_repo!=undef)
    {
      if($puppet::params::package_provider=='rpm')
      {
        file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs':
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => "puppet:///modules/${module_name}/RPM-GPG-KEY-puppetlabs",
          before => Package[$puppet::params::puppetlabs_package],
        }
      }

      download { 'puppetlabs repo puppet':
        url     => $puppet::params::puppetlabs_repo,
        creates => "${srcdir}/puppetlabs_repo.${puppet::params::package_provider}",
        require => Exec["mkdir p puppet ${srcdir}"],
      }

      package { $puppet::params::puppetlabs_package:
        ensure   => 'installed',
        provider => $puppet::params::package_provider,
        source   => "${srcdir}/puppetlabs_repo.${puppet::params::package_provider}",
        require  => Download['puppetlabs repo puppet'],
      }
    }
  }
}
