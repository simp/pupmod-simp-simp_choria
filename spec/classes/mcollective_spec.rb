require 'spec_helper'

describe 'simp_choria::mcollective' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts[:aio_agent_version] = '1.8.4'
        facts
      end

      context 'with default parameters' do
        it { is_expected.to create_class('mcollective').with({
          :server_config => { 'plugin.choria.ssldir' => '/var/lib/choria' },
          :client_config => { 'plugin.choria.ssldir' => '~/.choria' }
        }) }
      end

      # context 'with config specified' do
      #   let(:hieradata) {{
      #     'simp_choria::mcollective::config' => { 'facts_refresh_interval' => 15 }
      #   }}
      #   it { is_expected.to create_class('mcollective').with({
      #     :server_config => { 'plugin.choria.ssldir' => '/var/lib/choria' },
      #     :client_config => { 'plugin.choria.ssldir' => '~/.choria' },
      #     :facts_refresh_interval => 15
      #   }) }
      # end

      context 'with pki => true' do
        let(:params) {{ :pki => true }}
        it { is_expected.to create_pki__copy('choria') }
        it 'should create directories' do
          is_expected.to create_file('/var/lib/choria')
          is_expected.to create_file('/var/lib/choria/certificate_requests')
          is_expected.to create_file('/var/lib/choria/certs')
          is_expected.to create_file('/var/lib/choria/private_keys')
        end
        it 'should copy over certs' do
          is_expected.to create_file('/var/lib/choria/certificate_requests/testing.pem')
          is_expected.to create_file('/var/lib/choria/certs/testing.pem')
          is_expected.to create_file('/var/lib/choria/certs/ca.pem')
          is_expected.to create_file('/var/lib/choria/private_keys/testing.pem')
        end
      end

      context 'with firewall => true' do
        let(:params) {{ :firewall => true }}
        it { is_expected.to create_iptables__listen__tcp_stateful('choria middleware').with_dports([4222]) }
      end

    end
  end
end

