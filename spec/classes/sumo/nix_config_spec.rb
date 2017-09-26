require 'spec_helper'

RSpec.describe 'sumo::nix_config' do
  let(:facts) { { architecture: 'x86_64' } }

  context 'with manage_sources false' do
    let(:params) { { manage_sources: false, accessid: 'accessid', accesskey: 'accesskey' } }
    it { is_expected.not_to contain_file('/usr/local/sumo/sumo.json') }
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
    }
  end

  it { is_expected.to compile }

  it { is_expected.to contain_file('/usr/local/sumo') }
  it { is_expected.to contain_file('/usr/local/sumo/sumo.json') }
  it { is_expected.to contain_file('/etc/sumoVarFile.txt') }

  it { is_expected.to contain_exec('Download Sumo Executable') }
  it { is_expected.to contain_exec('Execute sumo') }
end
