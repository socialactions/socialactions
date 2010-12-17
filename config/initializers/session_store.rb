# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_socialactions238_session',
  :secret      => 'b6a00ec2ed581bebcdd29d07014a508ceb3efab79f107ad70296c4114cd40992f4c8e9f52431b29f8c1baa612a3b5954a3268cc5a5cc2c99fab285c7a31dbd7d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
