server ENV['PRODUCTION_IP'],
       user: ENV['SSH_USER'],
       roles: %w{web app db}, primary: true

set :ssh_options, {
  forward_agent: true,
  auth_methods: %w(publickey password),
  password: fetch(:password)
}

set :branch, 'develop'
set :deploy_to, '/var/www/wildlife-covid'

set :rails_env, :production
