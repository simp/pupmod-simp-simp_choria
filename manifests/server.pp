# Full description of SIMP module 'simp_choria' here.
#
# === Welcome to SIMP!
# This module is a component of the System Integrity Management Platform, a
# managed security compliance framework built on Puppet.
#
# ---
# *FIXME:* verify that the following paragraph fits this module's characteristics!
# ---
#
# This module is optimally designed for use within a larger SIMP ecosystem, but
# it can be used independently:
#
# * When included within the SIMP ecosystem, security compliance settings will
#   be managed from the Puppet server.
#
# * If used independently, all SIMP-managed security subsystems are disabled by
#   default, and must be explicitly opted into by administrators.  Please
#   review the +trusted_nets+ and +$enable_*+ parameters for details.
#
# @param trusted_nets
#   A whitelist of subnets (in CIDR notation) permitted access
#
# @param auditing
#   If true, manage auditing for simp_choria
#
# @param firewall
#   If true, manage firewall rules to acommodate simp_choria
#
# @param logging
#   If true, manage logging configuration for simp_choria
#
# @param pki
#   If true, manage PKI/PKE configuration for simp_choria
#
# @author simp
#
class simp_choria::server (
  Simplib::Port $nats_client_port,
  Hash $mco_server_config,
  Hash $mco_client_config,
  Hash $mco_config,
  Variant[Boolean,Enum['simp']] $pki = simplib::lookup('simp_options::pki', { 'default_value' => false }),
  Simplib::Netlist $trusted_nets = simplib::lookup('simp_options::trusted_nets', {'default_value' => ['127.0.0.1/32'] }),
  Boolean $auditing = simplib::lookup('simp_options::auditd', { 'default_value' => false }),
  Boolean $firewall = simplib::lookup('simp_options::firewall', { 'default_value' => false }),
  Boolean $logging = simplib::lookup('simp_options::syslog', { 'default_value' => false }),
) {
  include 'mcollective'

  $_server_config = $mco_server_config
  $_cert_dir = $_server_config['plugin.choria.ssldir']

  $_client_config = $mco_client_config

  class { 'mcollective':
    server_config => $_server_config,
    client_config => $_client_config,
    *             => $mco_config
  }

  if $firewall {
    iptables::listen::tcp_stateful { 'choria middleware':
      dports       => [$nats_client_port],
      trusted_nets => $trusted_nets
    }
  }

  if $pki {
    pki::copy { 'choria':
      pki => $pki,
    }

    file { $_cert_dir:
      ensure => directory
    }
    file {
      default:
        ensure  => directory,
        require => File[$_cert_dir];

      "${_cert_dir}/certificate_requests":;
      "${_cert_dir}/choria/certs":;
      "${_cert_dir}/choria/private_keys":;
    }
    file {
      default:
        ensure  => file,
        source  => "/etc/pki/simp_apps/choria/x509/private/${trusted['certname']}.pem",
        require => Pki::Copy['choria'],
        notify  => Class['mcollective'];

      "${_cert_dir}/certs/${trusted['certname']}.pem":;
      "${_cert_dir}/certificate_requests/${trusted['certname']}.pem":;
      "${_cert_dir}/private_keys/${trusted['certname']}.pem":;
      "${_cert_dir}/certs/ca.pem":
        source => '/etc/pki/simp_apps/choria/x509/cacerts/cacerts.pem';
    }
  }

}
