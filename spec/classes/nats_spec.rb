require 'spec_helper'

describe 'simp_choria::nats' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts[:aio_agent_version] = '1.8.4'
        facts
      end

      context 'with default parameters' do
        it { is_expected.to create_class('nats').with({
          :user         => 'nats',
          :group        => 'nats',
          :manage_user  => true,
          :manage_group => true,
        }) }
      end

      context 'with pki => true' do
        let(:params) {{ :pki => true }}
        it { is_expected.to create_class('nats').with({
          :user         => 'nats',
          :group        => 'nats',
          :manage_user  => true,
          :manage_group => true,
          :cert_file    => '/etc/pki/simp_apps/nats/x509/public/testing.pub',
          :key_file     => '/etc/pki/simp_apps/nats/x509/private/testing.pem',
          :ca_file      => '/etc/pki/simp_apps/nats/x509/cacerts/cacerts.pem',
          :require      => "Pki::Copy['nats']"
        }) }
        it { is_expected.to create_pki__copy('nats').with_owner('nats') }
      end

      context 'with a populated optional_params' do
        let(:params) {{
          :optional_params => {
            'announce_cluster' => true,
            'piddir'           => '/tmp/pid'
          }
        }}
        it { is_expected.to create_class('nats').with({
          :user         => 'nats',
          :group        => 'nats',
          :manage_user  => true,
          :manage_group => true,
          :announce_cluster => true,
          :piddir           => '/tmp/pid'
        }) }
      end

    end
  end
end

