# == Class simp_choria::config::logging
#
# This class is meant to be called from simp_choria.
# It ensures that logging rules are defined.
#
class simp_choria::config::logging {
  assert_private()

  # FIXME: ensure your module's logging settings are defined here.
  $msg = "FIXME: define the ${module_name} module's logging settings."

  notify{ 'FIXME: logging': message => $msg } # FIXME: remove this and add logic
  err( $msg )                                 # FIXME: remove this and add logic

}

