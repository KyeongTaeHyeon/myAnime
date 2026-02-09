threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
threads threads_count, threads_count

port ENV.fetch('SERVER_PORT', 8082)
environment ENV.fetch('RAILS_ENV', 'development')

plugin :tmp_restart
