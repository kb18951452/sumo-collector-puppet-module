# Class for sumologic nix config
class sumo::nix_config (
        $runAs_username         = undef,
) {
        ########## Parameters Section ##########
        $accessid               = $sumo::accessid
        $accesskey              = $sumo::accesskey
        $category               = $sumo::category
        $clobber                = $sumo::clobber
        $collector_name         = $sumo::collector_name
        $collector_secureFiles  = $sumo::collector_secureFiles
        $collector_url          = $sumo::collector_url
        $description            = $sumo::description
        $disableActionSource    = $sumo::disableActionSource
        $disableScriptSource    = $sumo::disableScriptSource
        $disableUpgrade         = $sumo::disableUpgrade
        $ephemeral              = $sumo::ephemeral
        $hostName               = $sumo::hostName
        $local_exec_file        = $sumo::local_exec_file
        $manage_download        = $sumo::manage_download
        $manage_sources         = $sumo::manage_sources
        $proxy_host             = $sumo::proxy_host
        $proxy_ntlmdomain       = $sumo::proxy_ntlmdomain
        $proxy_password         = $sumo::proxy_password
        $proxy_port             = $sumo::proxy_port
        $proxy_user             = $sumo::proxy_user
        $skipRegistration       = $sumo::skipRegistration
        $sources                = $sumo::sources
        $sumo_exec              = $sumo::sumo_exec
        $sumo_json_source_path  = $sumo::sumo_json_source_path
        $sumo_json_sync_source  = $sumo::sumo_json_sync_source
        $sumo_short_arch        = $sumo::sumo_short_arch
        $syncSources            = $sumo::syncSources
        $targetCPU              = $sumo::targetCPU
        $timeZone               = $sumo::timeZone
        $token                  = $sumo::token
        $winRunAs_password      = undef

        if ! defined(Class['sumo']) {
                fail('You must include the sumo base class before including any sumo sub classes')
        }

        Exec {
                path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
        }

        unless ($accessid != undef and $accesskey != undef) {
                fail(
                        'You must provide either an accesskey or accessid for the SumoLogic collector to connect with.'
                )
        }

        file { '/usr/local/sumo':
                ensure => 'directory',
                owner  => 'root',
                group  => 'root',
        }

        if $manage_sources {
                file { '/usr/local/sumo/sumo.json' :
                        ensure  => 'file',
                        owner   => 'root',
                        mode    => '0600',
                        group   => 'root',
                        source  => "puppet:///modules/sumo/json/$sumo_json_source_path",
                        require => File['/usr/local/sumo']
                }

                if ($syncSources and ($syncSources != $sources)) {
                        file { "$syncSources" :
                                ensure  => present,
                                source  => "puppet:///modules/sumo/json/$sumo_json_sync_source",
                                recurse => true,
                        }
                }
        }

        file {
                '/etc/sumo':
                ensure  => 'directory',
                owner   => 'root',
                group   => 'root',
                mode    => '0600';

                '/etc/sumo/sumoVarFile.txt':
                ensure  => 'file',
                owner   => 'root',
                group   => 'root',
                mode    => '0600',
                content => epp('sumo/sumoVarFile.txt.epp', {
                        'accessid'        => $accessid,
                        'accesskey'       => $accesskey,
                        'category'        => $category,
                        'clobber'         => $clobber,
                        'collector_name'  => $collector_name,
                        'collector_secureFiles'   => $collector_secureFiles,
                        'collector_url'   => $collector_url,
                        'description'     => $description,
                        'disableActionSource'     => $disableActionSource,
                        'disableScriptSource'     => $disableScriptSource,
                        'disableUpgrade'  => $disableUpgrade,
                        'ephemeral'       => $ephemeral,
                        'hostName'        => $hostName,
                        'proxy_host'      => $proxy_host,
                        'proxy_ntlmdomain' => $proxy_ntlmdomain,
                        'proxy_password'  => $proxy_password,
                        'proxy_port'      => $proxy_port,
                        'proxy_user'      => $proxy_user,
                        'runAs_username'  => $runAs_username,
                        'skipRegistration'        => $skipRegistration,
                        'sources'         => $sources,
                        'syncSources'     => $syncSources,
                        'targetCPU'       => $targetCPU,
                        'timeZone'        => $timeZone,
                        'winRunAs_password'        => $winRunAs_password,
                }),
        }

        if $manage_download {
                exec { 'Download Sumo Executable' :
                        command => "curl -o /usr/local/sumo/${sumo_exec} https://collectors.sumologic.com/rest/download/linux/${sumo_short_arch}",
                        creates => "/usr/local/sumo/${sumo_exec}",
                        require => File['/usr/local/sumo'],
                        notify  => Exec['Execute sumo'],
                }

                exec { 'Execute sumo':
                        command => "sh /usr/local/sumo/${sumo_exec} -q -varfile /etc/sumo/sumoVarFile.txt",
                        creates => '/opt/SumoCollector/jre',
                        require => File['/etc/sumo/sumoVarFile.txt'],
                        notify  => Service['collector'],
                }
        } else {
                if ( local_exec_file == undef ) { fail('You must provide the file to be installed that must be present in tne puppet:///modules/sumo/packages folder.') }

                case $::osfamily {
                        'redhat' : {
                                $local_provider    = 'rpm'
                        }
                        'debian' : {
                                $local_provider    = 'dpkg'
                        }
                        default: { fail("there is no supported operating system family ${::osfamily}") }
                }

                file { '/opt/SumoCollector/config/user.properties':
                        ensure  => 'file',
                        owner   => 'root',
                        group   => 'root',
                        mode    => '0600',
                        content => epp('sumo/user.properties.epp', {
                                  'accessid'        => $accessid,
                                  'accesskey'       => $accesskey,
                                  'category'        => $category,
                                  'clobber'         => $clobber,
                                  'collector_name'  => $collector_name,
                                  'collector_secureFiles'   => $collector_secureFiles,
                                  'collector_url'   => $collector_url,
                                  'description'     => $description,
                                  'disableActionSource'     => $disableActionSource,
                                  'disableScriptSource'     => $disableScriptSource,
                                  'disableUpgrade'  => $disableUpgrade,
                                  'ephemeral'       => $ephemeral,
                                  'hostName'        => $hostName,
                                  'proxy_host'      => $proxy_host,
                                  'proxy_ntlmdomain' => $proxy_ntlmdomain,
                                  'proxy_password'  => $proxy_password,
                                  'proxy_port'      => $proxy_port,
                                  'proxy_user'      => $proxy_user,
                                  'runAs_username'  => $runAs_username,
                                  'skipRegistration'        => $skipRegistration,
                                  'sources'         => $sources,
                                  'syncSources'     => $syncSources,
                                  'targetCPU'       => $targetCPU,
                                  'timeZone'        => $timeZone,
                                  'token'           => $token,
                        }),
                        require => Package['SumoCollector'],
                        notify  => Service['collector'];
                }

                file { "/usr/local/sumo/$local_exec_file":
                        ensure => 'file',
                        owner  => 'root',
                        group  => 'root',
                        mode   => '0755',
                        source => "puppet:///modules/sumo/packages/$local_exec_file";
                }

                package { 'SumoCollector' :
                        ensure          => 'installed',
                        source          => "/usr/local/sumo/$local_exec_file",
                        provider        => $local_provider,
                        require         => File["/usr/local/sumo/$local_exec_file"],
                }
        }

        service { 'collector' :
                ensure  => 'running',
                enable  => true,
        }
}
