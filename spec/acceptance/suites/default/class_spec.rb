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
    let(:manifest) { "class { 'simp_choria': is_middleware => true }" }
    it 'should work with no errors' do
      set_hieradata_on(host, stock_hiera)
      apply_manifest_on(host, manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      sleep(15)
      apply_manifest_on(host, manifest, :catch_changes => true)
    end
  end

  servers.each do |server|
    let(:manifest) { "class { 'simp_choria': }" }
    it 'should work with no errors' do
      apply_manifest_on(server, manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest_on(server,manifest, :catch_changes => true)
    end
  end

  clients.each do |client|
    it 'should copy over user certs' do
      # lets see if the rest works first
      on client, '/bin/false'
    end
  end

end
