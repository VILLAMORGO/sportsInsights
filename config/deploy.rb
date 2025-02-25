# Change these
server '54.242.52.240', user: 'ubuntu', roles: [:web, :app, :db], primary: true

set :repo_url, 'git@github.com:VILLAMORGO/sportsInsights.git'
set :application, 'sportsInsights'
set :branch, 'main'

set :user, 'ubuntu'
set :puma_threads, [4, 16]
set :puma_workers, 0

set :pty, true
set :use_sudo, false
set :stage, :production
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log, "#{release_path}/log/puma.error.log"
set :pty, true

set :ssh_options, {
  forward_agent: true,
  auth_methods: ["publickey"],
  keys: ["sport_insight.pem"]
}

set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

append :rbenv_map_bins, 'puma', 'pumactl'

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before 'deploy:starting', 'puma:make_dirs'

  desc 'Restart Puma'
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, 'puma_sportsInsights_production.service'
    end
  end
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/main`
        puts "WARNING: HEAD is not the same as origin/main"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after :finishing, 'compile_assets'
  after :finishing, 'cleanup'
end

namespace :puma_config do
  desc "remove index.php"
  task :rm_files do
      on roles(:all) do
              execute "rm -rf #{release_path}/config/puma.rb"
      end
  end
end

namespace :puma_config do
  desc "add symlink to index.php"
  task :add_files do
      on roles(:all) do
              execute "ln -sf #{shared_path}/puma.rb #{release_path}/config/puma.rb"
      end
  end
end

after "deploy:finished", "puma_config:rm_files"
after "deploy:finished", "puma_config:add_files"

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
