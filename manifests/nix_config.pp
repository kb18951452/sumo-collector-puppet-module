# Class for sumologic nix config
class sumo::nix_config (
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

  file { '/usr/local/sumo':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
  }

  if $manage_sources {
    file { '/usr/local/sumo/sumo.json':
      ensure  => present,
      owner   => 'root',
      mode    => '0600',
      group   => 'root',
      source  => $sumo::sumo_json_source_path,
      require => File['/usr/local/sumo']
    }
  }

  file { '/etc/sumoVarFile.txt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('sumo/sumoVarFile.txt.erb')
  }

  exec { 'Download Sumo Executable':
    command => "/usr/bin/curl -o /usr/local/sumo/${sumo_exec} https://collectors.sumologic.com/rest/download/linux/${sumo_short_arch}",
    cwd     => '/usr/bin',
    creates => "/usr/local/sumo/${sumo_exec}",
    require => File['/usr/local/sumo'],
  }

  exec { 'Execute sumo':
    command => "/bin/sh /usr/local/sumo/${sumo_exec} -q -varfile /etc/sumoVarFile.txt",
    cwd     => '/usr/local/sumo',
    creates => '/opt/SumoCollector',
    require => [
      Exec['Download Sumo Executable'],
      File['/etc/sumoVarFile.txt'],
  }
}