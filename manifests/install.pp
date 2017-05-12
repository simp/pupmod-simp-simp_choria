# == Class simp_choria::install
#
# This class is called from simp_choria for install.
#
class simp_choria::install {
  assert_private()

  package { $::simp_choria::package_name:
    ensure => present
  }
}
