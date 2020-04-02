class { 'snmpd':
  add_default_acls => false,
}

class { 'snmpd::loadavg': }

snmpd::v3user { 'v3testuser':
  authpass => '1234567890',
  encpass  => '1234567890',
}

class { 'puppet::agent':
  puppetmaster     => 'lolmaster',
  puppetmasterport => '1234',
}
