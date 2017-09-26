# class for sumologic windows config
class sumo::win_config (
  $accessid               = $sumo::accessid,
  $accesskey              = $sumo::accesskey,
  $category               = $sumo::category,
  $clobber                = $sumo::clobber,
  $collector_name         = $sumo::collector_name,
  $description            = $sumo::description,
  $disableActionSource    = $sumo::disableActionSource,
  $disableScriptSource    = $sumo::disableScriptSource,
  $disableUpgrade         = $sumo::disableUpgrade,
  $ephemeral              = $sumo::ephemeral,
  $hostName               = $sumo::hostName,
  $manage_sources         = $sumo::manage_sources,
  $proxy_host             = $sumo::proxy_host,
  $proxy_ntlmdomain       = $sumo::proxy_ntlmdomain,
  $proxy_password         = $sumo::proxy_password,
  $proxy_port             = $sumo::proxy_port,
  $proxy_user             = $sumo::proxy_user,
  $sources                = $sumo::sources,
  $sumo_json_source_path  = $sumo::sumo_json_source_path,
  $sumo_exec              = $sumo::sumo_exec,
  $sumo_short_arch        = $sumo::sumo_short_arch,
  $syncsources            = $sumo::syncsources,
  $targetCPU              = $sumo::targetCPU,
  $timeZone               = $sumo::timeZone,
  $url                    = $sumo::url,
) {
  unless ($accessid != undef and $accesskey != undef) {
    fail(
      'You must provide either an accesskey and accessid for the SumoLogic collector to connect with.'
    )
  }

  file {
    'C:\sumo\download_sumo.ps1':
      ensure  => present,
      mode    => '0777',
      group   => 'Administrators',
      source  => 'puppet:///modules/sumo/download_sumo.ps1',
      require => File['C:\sumo'];

    'C:\sumo':
      ensure => directory,
      mode   =>  '0777',
      group  => 'Administrators';
  }

  if $manage_sources {
    file { 'C:\sumo\sumo.json':
      ensure  => present,
      mode    => '0644',
      group   => 'Administrators',
      source  => $sumo::sumo_json_source_path,
      require => File['C:\sumo'],
    }
  }

  file { 'C:\sumo\sumoVarFile.txt':
    ensure  => present,
    mode    => '0644',
    group   => 'Administrators',
    content => template('sumo/sumoVarFile.txt.erb'),
    require => File['C:\sumo'];
  }

  $powershell_path = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'
  exec { 'download_sumo':
    command => "${powershell_path} -executionpolicy remotesigned -file C:\\sumo\\download_sumo.ps1",
    require => File['C:\sumo\download_sumo.ps1'],
    creates => 'C:\sumo\sumo.exe'
  }

  package { 'sumologic':
    ensure          => installed,
    install_options => ['-q', '-varfile' => 'C:\sumo\sumoVarFile.txt'],
    source          => 'C:\sumo\sumo.exe',
    require         => [
      Exec['download_sumo'],
      File['C:\sumo\sumoVarFile.txt'],
    ]
  }
}
