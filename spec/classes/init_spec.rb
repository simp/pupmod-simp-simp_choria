require 'spec_helper'

describe 'simp_choria' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts[:aio_agent_version] = '1.8.4'
        facts
      end

      context 'with default parameters' do
        it { is_expected.to create_class('simp_choria::mcollective') }
      end

      context 'as a middleware server' do
        let(:params) {{ :is_middleware => true }}
        it { is_expected.to create_class('simp_choria::mcollective') }
        it { is_expected.to create_class('simp_choria::nats') }
      end

    end
  end
end
