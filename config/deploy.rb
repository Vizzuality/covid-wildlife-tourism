# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

set :application, "covid-wildlife-tourism"
set :repo_url, "git@github.com:Vizzuality/covid-wildlife-tourism.git"

set :default_env, {
    'PATH' => "/usr/share/rvm/rubies/ruby-2.6.3/bin/ruby:/usr/share/rvm:/usr/share/rvm/bin/rvm:$PATH",
    'RUBY_VERSION' => '2.6.3',
    'GEM_HOME' => '/usr/share/rvm/rubies/ruby-2.6.3',
    'GEM_PATH' => '/usr/share/rvm/rubies/ruby-2.6.3',
    'BUNDLE_PATH' => '/usr/share/rvm/rubies/ruby-2.6.3'
}

set :passenger_restart_with_touch, true

set :rvm_type, :user
set :rvm_ruby_version, '2.6.3'
set :rvm_roles, [:app, :web, :db]

append :linked_files, '.env', 'config/master.key'

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/packs", "public/system", 'db/files', 'config/credentials'

set :user, 'ubuntu'

set :nvm_node, 'v12.16.1'
set :nvm_type, :user
set :nvm_map_bins, %w{node npm yarn}

set :logrotate_logs_keep, -> { 12 }
set :logrotate_interval, -> { 'monthly' }


namespace :nvm do
  namespace :webpacker do
    task :validate => [:'nvm:map_bins'] do
      on release_roles(fetch(:nvm_roles)) do
        within release_path do
          if !test('node', '--version')
            warn "node is not installed"
            exit 1
          end

          if !test('yarn', '--version')
            warn "yarn is not installed"
            exit 1
          end
        end
      end
    end

    task :wrap => [:'nvm:map_bins'] do
      on roles(:web) do
        SSHKit.config.command_map.prefix['rake'].unshift(nvm_prefix)
      end
    end

    task :unwrap do
      on roles(:web) do
        SSHKit.config.command_map.prefix['rake'].delete(nvm_prefix)
      end
    end

    def nvm_prefix
      fetch(
          :nvm_prefix, -> {
        "#{fetch(:tmp_dir)}/#{fetch(:application)}/nvm-exec.sh"
      }
      )
    end

    after 'nvm:validate', 'nvm:webpacker:validate'
    before 'deploy:assets:precompile', 'nvm:webpacker:wrap'
  end
end
