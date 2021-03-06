class perfsonar::mesh_config::config(
  $agentconfig = $::perfsonar::params::mesh_config_agent,
) inherits perfsonar::params {
  $agent_options = merge($perfsonar::params::agentconfig, $agentconfig)
  file { '/etc/perfsonar/meshconfig-agent.conf':
    ensure  => 'present',
    owner   => 'perfsonar',
    group   => 'perfsonar',
    mode    => '0644',
    content => template("${module_name}/agent_configuration.conf.erb"),
    require => Package['perfsonar-meshconfig-agent'],
  }
  # needs notty in sudoers
  exec { 'generate mesh configuration':
    command     => '/usr/bin/sudo -u perfsonar /usr/lib/perfsonar/bin/generate_configuration',
    logoutput   => 'on_failure',
    subscribe   => File['/etc/perfsonar/meshconfig-agent.conf'],
    require     => [
      Exec['run regular testing configuration script'],
      File['/etc/sudoers.d/perfsonar_mesh_config'],
    ],
    refreshonly => true,
    notify      => Service['perfsonar-regulartesting'],
  }
  file { '/etc/sudoers.d/perfsonar_mesh_config':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    content => "Defaults!/usr/lib/perfsonar/bin/generate_configuration !requiretty\n",
  }
}
