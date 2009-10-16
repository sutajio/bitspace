# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bitspace_session',
  :secret      => '245e7efe9a485bb3f1b451b3f4e1add351573e5c7ffa24d20ce83cf60ac81b5a22a40c4f8c7ab2f2f85252e2e2e4d67bf4627e19a418182a1c88b7424085470b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
