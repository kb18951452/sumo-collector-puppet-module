# The official SumoLogic collector puppet module
class sumo (
  $accessid              = undef,
  $accesskey             = undef,
  $category              = undef,
  $clobber               = false,
  $collector_name        = undef,
  $description           = undef,
  $disableActionSource   = undef,
  $disableScriptSource   = undef,
  $disableUpgrade        = undef,
  $ephemeral             = false,
  $hostName              = undef,
  $manage_sources        = false,
  $proxy_host            = undef,
  $proxy_ntlmdomain      = undef,
  $proxy_password        = undef,
  $proxy_port            = undef,
  $proxy_user            = undef,
  $sources               = $sumo::params::sources,
  $sumo_json_source_path = $sumo::params::sumo_json_source_path,
  $sumo_exec             = $sumo::params::sumo_exec,
  $sumo_short_arch       = $sumo::params::sumo_short_arch,
  $syncsources           = $sumo::params::syncsources,
  $targetCPU             = undef,
  $timeZone              = undef,
  $url                   = undef,
) inherits sumo::params {
  if $::osfamily == 'windows'{
    class { 'sumo::win_config': }
  } else {
    class { 'sumo::nix_config': }
  }
}
