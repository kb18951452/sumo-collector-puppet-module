# class for sumologic windows config
class sumo::win_config (
        $runAs_username         = undef,
        $winRunAs_password      = undef,
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
        $sumo_json_source_path  = $sumo::sumo_json_source_path
        $sumo_json_sync_source  = $sumo::sumo_json_sync_source
        $sumo_win_arch          = $sumo::sumo_win_arch
        $syncSources            = $sumo::syncSources
        $targetCPU              = $sumo::targetCPU
        $timeZone               = $sumo::timeZone

        if ! defined(Class['sumo']) {
                fail('You must include the sumo base class before including any sumo sub classes')
        }

        unless ($accessid != undef and $accesskey != undef) {
                fail(
                        'You must provide either an accesskey or accessid for the SumoLogic collector to connect with.'
                )
        }

        file {
                'C:/sumo':
                ensure => 'directory',
                mode   =>  '0777',
                group  => 'Administrators';

                'C:/sumo/download_sumo.ps1':
                ensure  => 'file',
                mode    => '0777',
                group   => 'Administrators',
                content => epp('sumo/download_sumo.ps1.epp', { 'sumo_win_arch'       => $sumo_win_arch }),
                require => File['C:/sumo'];
        }

        if $manage_sources {
                file { 'C:/sumo/sumo.json':
                        ensure  => 'file',
                        mode    => '0775',
                        group   => 'Administrators',
                        source  => "puppet:///modules/sumo/json/$sumo_json_source_path",
                        require => File['C:/sumo'],
                }

                if ($syncSources and ($syncSources != $sources)) {
                        file { "$syncSources" :
                                ensure  => present,
                                source  => "puppet:///modules/sumo/json/$sumo_json_sync_source",
                                recurse => true,
                        }
                }
        }

        file { 'C:/sumo/sumoVarFile.txt':
                ensure  => 'file',
                mode    => '0664',
                group   => 'Administrators',
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
                        'winRunAs_password'       => $winRunAs_password
                }),
                require => File['C:/sumo'];
        }

        if $manage_download {
                $powershell_path = 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
                exec { 'download_sumo' :
                        command => "${powershell_path} -executionpolicy remotesigned -file C:/sumo/download_sumo.ps1",
                        require => File['C:/sumo/download_sumo.ps1'],
                        creates => 'C:/sumo/sumo.exe',
                        before  => Exec['Install sumologic'],
                }
        } else {
                file { 'c:/sumo/sumo.exe' :
                        ensure  => 'file',
                        group   => 'Administrators',
                        mode    => '0775',
                        source  => "puppet:///modules/sumo/packages/$local_exec_file",
                        before  => Exec['Install sumologic'],
                }
        }

        case $::architecture {
                'x86': {
                        $progFiles = 'C:/Program Files (x86)'
                }
                default: {
                        $progFiles = 'C:/Program Files'
                }
        }

        exec { 'Install sumologic':
                command => 'C:/sumo/sumo.exe -q -varfile C:/sumo/sumoVarFile.txt',
                creates => "$progFiles/Sumo Logic Collector/collector.bat",
                require => File['C:/sumo/sumoVarFile.txt'],
                notify  => Service['sumo-collector'],
        }

        file { 'C:/Program Files/Sumo Logic Collector/config/user.properties':
                ensure  => 'file',
                require => Exec['Install sumologic'],
        }

        service { 'sumo-collector':
                ensure      => 'running',
                enable      => 'true',
                subscribe   => File['C:/Program Files/Sumo Logic Collector/config/user.properties'],
        }
}
