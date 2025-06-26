Rails.application.config.session_store :cookie_store,
  key: "_routine_session",
  expire_after: nil,  # Never expire sessions
  secure: false       # Allow HTTP cookies
