sumo-collector-puppet-module
============================

Puppet module for installing Sumo Logic's collector. This downloads the sumo
logic agent from the Internet, so Internet access is required on your machines.

## Usage
```Puppet
class { 'sumo':
  accessid       => 'accessid',
  accesskey      => 'accesskey',
  manage_sources => false,
}
```

## Parameters
This module supports almost all of the installation configuration options listed in
SumoLogic's [documentation](https://help.sumologic.com/Send-Data/Installed-Collectors/05Reference-Information-for-Collector-Installation/06Parameters-for-the-Command-Line-Installer).  Head there
for a full explanation of what each option does to the SumoLogic collector.

The only required parameters are a pair of authentication parameters: `accessid` and `accesskey`.

| Parameter Name        | Description                                            | Default value (in the module, not the collector)
|-----------------------|--------------------------------------------------------|-------------------------------------------------
| accessid              | The access id for the collector to register with       | undef
| accesskey             | The access key for the collector to register with      | undef
| clobber               | Whether you want to clobber the collector              | false
| collector_name        | Name of the collector                                  | undef
| collector_secureFiles | Enable Enhanced File System Security                   | undef
| collector_url 		| URL used to register Collector for data collection API | undef
| description 			| Description for the Collector to appear in Sumo Logic. | undef
| disableActionSource 	| Action Source will not execute on this Collector.      | undef
| disableScriptSource 	| Script Source will not execute on this Collector       | undef
| disableUpgrade 		| Collector rejects upgrade requests from Sumo Logic.    | undef
| ephemeral             | Whether to mark the collector as ephemeral             | false
| hostName 				| The host name of the machine on which the Collector is running.                                  				| undef
| manage_sources        | If you want this module to manage your sources file    | false
| proxy_host            | When using a proxy, the hostname to connect to         | undef
| proxy_ntlmdomain      | When using an NTML proxy, the URL used to connect      | undef
| proxy_password        | When using a proxy, the password to use to connect     | undef
| proxy_port            | When using a proxy, the port to connect to             | undef
| proxy_user            | When using a proxy, the user to connect as             | undef
| runAs_username 		| When set, the Collector will run as the specified user (Windows and Linux).                                  	| undef
| skipRegistration 		| Collector will install files and create user.properties file, but not register or start the collector.        | undef
| sources               | The destination (on disk) of your sources file         | platform specific
| sumo_json_source_path | The Puppet URL for your sumo.json file                 | puppet:///modules/sumo/sumo.json
| sumo_exec             | The installation executable name                       | architecture specific
| sumo_short_arch       | The shortened architecture to download                 | architecture specific
| syncsources           | For Local File Configuration, the sources file to sync | $sources
| targetCPU 			| Set a CPU target to limit the amount of CPU processing a Collector uses.                                  	| undef
| timeZone 				| The time zone to use when the time zone can't be extracted from the time stamp.                               | undef
| winRunAs_password 	| The Collector will run as the specified runAs_username with the specified password.                           | undef

## Testing / Contributing
See [CONTRIBUTING.md](https://github.com/SumoLogic/sumo-collector-puppet-module/blob/master/CONTRIBUTING.md).