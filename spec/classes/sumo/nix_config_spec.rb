require 'spec_helper'

RSpec.describe 'sumo::nix_config' do
  let(:facts) { { architecture: 'x86_64', kernel: 'linux', osfamily: 'RedHat' } }

  context 'with manage_sources false' do
    let(:params) { { manage_sources: false, accessid: 'accessid', accesskey: 'accesskey' } }
    it { is_expected.not_to contain_file('/usr/local/sumo/sumo.json') }
  end

  context 'with manage_download false and only accessid/accesskey' do
    let(:params) { {  accessid: 'accessid', accesskey: 'accesskey', manage_download: false, local_exec_file: 'local_exec_file' } }
    it { is_expected.not_to contain_exec('Download Sumo Executable') }
    it { is_expected.not_to contain_exec('Execute sumo') }
    it { is_expected.to contain_file('/usr/local/sumo/user.properties') }
    it { is_expected.to contain_package('SumoCollector') }
    it { is_expected.to compile }
  end

  context 'with manage_download false' do
    let(:params) { {  manage_sources: false, accessid: 'accessid', accesskey: 'accesskey', manage_download: false, local_exec_file: 'local_exec_file' } }
    it { is_expected.not_to contain_exec('Download Sumo Executable') }
    it { is_expected.not_to contain_exec('Execute sumo') }
    it { is_expected.to contain_file('/usr/local/sumo/user.properties') }
    it { is_expected.to contain_package('SumoCollector') }
  end

  context 'with manage_download false and no local_exec_file' do
    let(:params) { { manage_download: false } }
    it { is_expected.to compile.and_raise_error(/You must provide/) }
  end

  context 'with no accessid/accesskey' do
    let(:params) { { } }
    it { is_expected.to compile.and_raise_error(/You must provide/) }
  end

  let(:params) do
    {
      manage_sources: true,
      accessid: 'accessid',
      accesskey: 'accesskey',
      manage_download: true,
    }
  end

  it { is_expected.to compile }

  it { is_expected.to contain_file('/usr/local/sumo') }
  it { is_expected.to contain_file('/usr/local/sumo/sumo.json') }
  it { is_expected.to contain_file('/etc/sumo/sumoVarFile.txt') }

  it { is_expected.to contain_exec('Download Sumo Executable') }
  it { is_expected.to contain_exec('Execute sumo') }

  it { is_expected.to contain_service('collector') }
end
