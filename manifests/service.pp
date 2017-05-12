# == Class simp_choria::service
#
# This class is meant to be called from simp_choria.
# It ensure the service is running.
#
class simp_choria::service {
  assert_private()

  service { $::simp_choria::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }
}
