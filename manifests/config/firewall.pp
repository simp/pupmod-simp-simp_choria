# == Class simp_choria::config::firewall
#
# This class is meant to be called from simp_choria.
# It ensures that firewall rules are defined.
#
class simp_choria::config::firewall {
  assert_private()

  # FIXME: ensure your module's firewall settings are defined here.
  iptables::listen::tcp_stateful { 'allow_simp_choria_tcp_connections':
    trusted_nets => $::simp_choria::trusted_nets,
    dports       => $::simp_choria::tcp_listen_port
  }
}
