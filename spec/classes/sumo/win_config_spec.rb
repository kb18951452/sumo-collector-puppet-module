require 'spec_helper'

RSpec.describe 'sumo::win_config' do
  let(:facts) { { architecture: 'x64', kernel: 'windows', osfamily: 'windows' } }

  context 'with manage_sources false' do
    let(:params) { { manage_sources: false, accessid: 'accessid', accesskey: 'accesskey' } }
    it { is_expected.not_to contain_file('C:/sumo/sumo.json') }
  end

  context 'with manage_download false' do
    let(:params) { { manage_sources: false, accessid: 'accessid', accesskey: 'accesskey', manage_download: false, local_exec_file: 'local_exec_file' } }
    it { is_expected.not_to contain_exec('download_sumo') }
  end

  context 'with manage_download false and without manage_sources' do
    let(:params) { { accessid: 'accessid', accesskey: 'accesskey', manage_download: false, local_exec_file: 'local_exec_file' } }
    it { is_expected.not_to contain_exec('download_sumo') }
    it { is_expected.to compile }
  end

  context 'with only accessid and accesskey' do
    let(:params) { { accessid: 'accessid', accesskey: 'accesskey' } }
    it { is_expected.to compile }
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

  it { is_expected.to contain_file('C:/sumo/download_sumo.ps1') }
  it { is_expected.to contain_file('C:/sumo') }
  it { is_expected.to contain_file('C:/sumo/sumo.json') }
  it { is_expected.to contain_file('C:/sumo/sumoVarFile.txt') }

  it { is_expected.to contain_exec('download_sumo') }
  it { is_expected.to contain_exec('Install sumologic') }

  it { is_expected.to contain_service('sumo-collector') }
end
