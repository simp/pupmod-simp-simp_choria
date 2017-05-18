require 'spec_helper_acceptance'

test_name 'simp_choria'

describe 'simp_choria' do
  nats = hosts_with_role(hosts, 'middleware')
  servers = hosts_with_role(hosts, 'server')
  clients = hosts_with_role(hosts, 'client')

  stock_hiera = {
    'simp_options::pki' => true,
    'simp_options::pki::source' => '/etc/pki/simp-testing/pki'
  }

  nats.each do |host|
    let(:nats_manifest) { "class { 'simp_choria': is_middleware => true }" }
    it 'should work with no errors' do
      set_hieradata_on(host, stock_hiera)
      apply_manifest_on(host, nats_manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      sleep 30
      apply_manifest_on(host, nats_manifest, :catch_changes => true)
    end
  end

  servers.each do |server|
    let(:mco_manifest) { "class { 'simp_choria': }" }
    it 'should work with no errors' do
      set_hieradata_on(server, stock_hiera)
      apply_manifest_on(server, mco_manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest_on(server, mco_manifest, :catch_failures => true)
      apply_manifest_on(server, mco_manifest, :catch_changes => true)
    end
  end

  clients.each do |client|
    let(:middleware_fqdn) { fact_on(nats[0], 'fqdn') }
    let(:hiera) do
      stock_hiera.merge({
        'mcollective::client' => true,
        'simp_choria::config' => {
          'config' => {
            'server_config' => {
              'plugin.choria.security.certname_whitelist' => '*'
            }
          }
        },
        'mcollective_choria::config' => {
          'use_srv_records'  => false,
          'middleware_hosts' => "#{middleware_fqdn}:4222"
        }
      })
    end
    let(:client_fqdn) { fact_on(client, 'fqdn') }
    it 'should work with no errors' do
      set_hieradata_on(client, hiera)
      apply_manifest_on(client, nats_manifest, :catch_failures => true)
    end
    it 'should use the host certs as user certs' do
      on(client, <<-EOF
        set -e
        mkdir -p ~vagrant/.choria/{certs,private_keys,certificate_requests}
        cp /etc/pki/simp-testing/pki/private/*.pem ~vagrant/.choria/certs/
        cp /etc/pki/simp-testing/pki/private/*.pem ~vagrant/.choria/private_keys/
        cp /etc/pki/simp-testing/pki/private/*.pem ~vagrant/.choria/certificate_requests/
        cp /etc/pki/simp-testing/pki/cacerts/cacerts.pem ~vagrant/.choria/certs/ca.pem
        chown -R vagrant.vagrant ~vagrant/.choria/
      EOF
      )
    end
    it 'should detect a valid cert configuration' do
      on(client, %Q{su -l vagrant -c 'MCOLLECTIVE_CERTNAME=#{client_fqdn} mco choria show_config' | grep -v absent} )
    end
    it 'should run mco ping with 3 results' do
      require 'pry';binding.pry
      result = on(client, %Q{su -l vagrant -c 'MCOLLECTIVE_CERTNAME=#{client_fqdn} mco ping'})
    end
    # it 'should request a cert using the Puppet CA' do
    #   on(client, 'mco choria request_cert')
    # end
    # it 'should run mco ping and get 3 lines of responses' do
    #   on(client, 'mco ping')
    # end

    it 'should copy over user certs' do
      # lets see if the rest works first
      on client, '/bin/false'
    end
  end

end
