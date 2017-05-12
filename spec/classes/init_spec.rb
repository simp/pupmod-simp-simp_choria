require 'spec_helper'

describe 'simp_choria' do
  shared_examples_for "a structured module" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('simp_choria') }
    it { is_expected.to contain_class('simp_choria') }
    it { is_expected.to contain_class('simp_choria::install').that_comes_before('Class[simp_choria::config]') }
    it { is_expected.to contain_class('simp_choria::config') }
    it { is_expected.to contain_class('simp_choria::service').that_subscribes_to('Class[simp_choria::config]') }

    it { is_expected.to contain_service('simp_choria') }
    it { is_expected.to contain_package('simp_choria').with_ensure('present') }
  end


  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "simp_choria class without any parameters" do
          let(:params) {{ }}
          it_behaves_like "a structured module"
          it { is_expected.to contain_class('simp_choria').with_trusted_nets(['127.0.0.1/32']) }
        end

        context "simp_choria class with firewall enabled" do
          let(:params) {{
            :trusted_nets     => ['10.0.2.0/24'],
            :tcp_listen_port => 1234,
            :enable_firewall => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('simp_choria::config::firewall') }

          it { is_expected.to contain_class('simp_choria::config::firewall').that_comes_before('Class[simp_choria::service]') }
          it { is_expected.to create_iptables__listen__tcp_stateful('allow_simp_choria_tcp_connections').with_dports(1234)
          }
        end

        context "simp_choria class with selinux enabled" do
          let(:params) {{
            :enable_selinux => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('simp_choria::config::selinux') }
          it { is_expected.to contain_class('simp_choria::config::selinux').that_comes_before('Class[simp_choria::service]') }
          it { is_expected.to create_notify('FIXME: selinux') }
        end

        context "simp_choria class with auditing enabled" do
          let(:params) {{
            :enable_auditing => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('simp_choria::config::auditing') }
          it { is_expected.to contain_class('simp_choria::config::auditing').that_comes_before('Class[simp_choria::service]') }
          it { is_expected.to create_notify('FIXME: auditing') }
        end

        context "simp_choria class with logging enabled" do
          let(:params) {{
            :enable_logging => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('simp_choria::config::logging') }
          it { is_expected.to contain_class('simp_choria::config::logging').that_comes_before('Class[simp_choria::service]') }
          it { is_expected.to create_notify('FIXME: logging') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'simp_choria class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('simp_choria') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
