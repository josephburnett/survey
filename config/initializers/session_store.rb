Rails.application.config.session_store :cookie_store,
  key: "_routine_session",
  expire_after: 1.week,     # Sessions last 1 week
  secure: false,            # Allow HTTP cookies (since you're on local network)
  httponly: true,           # Prevent XSS attacks
  same_site: :lax           # Better mobile compatibility
