#
class puppet::agent::config inherits puppet::agent {
  #
  file { '/etc/salt/agent':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("${module_name}/agent/agent.erb"),
  }

  if(defined(Class['logrotate']))
  {
    logrotate::logs { 'puppet-client':
      log          => $puppet::agent::log,
      compress     => true,
      copytruncate => true,
      frequency    => 'daily',
      rotate       => $puppet::agent::logrotate_rotate,
      missingok    => true,
      size         => $puppet::agent::logrotate_maxsize,
    }
  }
}
