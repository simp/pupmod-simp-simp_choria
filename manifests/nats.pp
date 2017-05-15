# Manage NATS with SIMP integration
#
# @TODO support clustering
class simp_choria::nats (
  Simplib::Port $client_port,
  Boolean $debug,
  Boolean $trace,
  String $user,
  String $group,
  Hash $optional_params,
  Simplib::Netlist $trusted_nets = simplib::lookup('simp_options::trusted_nets', {'default_value' => ['127.0.0.1/32'] }),
  Boolean $firewall = simplib::lookup('simp_options::firewall', { 'default_value' => false }),
  Variant[Boolean,Enum['simp']] $pki = simplib::lookup('simp_options::pki', { 'default_value' => false }),
  Stdlib::Absolutepath $app_pki_dir = '/etc/pki/simp_apps/nats/x509',
  Stdlib::AbsolutePath $app_pki_cert = "${app_pki_dir}/public/${trusted['certname']}.pub",
  Stdlib::AbsolutePath $app_pki_key = "${app_pki_dir}/private/${trusted['certname']}.pem",
  Stdlib::AbsolutePath $app_pki_ca = "${app_pki_dir}/cacerts/cacerts.pem",
) {

  if $firewall {
    iptables::listen::tcp_stateful { 'choria middleware':
      dports       => [$client_port],
      trusted_nets => $trusted_nets
    }
  }

  if $pki {
    pki::copy { 'nats':
      pki   => $pki,
      owner => $user,
      group => $group
    }
    $_pki_params = {
      'cert_file' => $app_pki_cert,
      'key_file'  => $app_pki_key,
      'ca_file'   => $app_pki_ca,
      'require'   => "Pki::Copy['nats']"
    }
  }
  else {
    $_pki_params = {}
  }

  $_passthru_params = {
    'manage_user'  => true,
    'manage_group' => true,
    'user'         => $user,
    'group'        => $group,
    'client_port'  => String($client_port),
    'debug'        => $debug,
    'trace'        => $trace,
  }

  class { 'nats':
    * => $_passthru_params + $_pki_params + $optional_params
  }

}