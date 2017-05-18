# Container class
class simp_choria (
  Boolean $is_middleware,
) {
  include 'simp_choria::mcollective'

  if $is_middleware {
    include 'simp_choria::nats'
  }

}
