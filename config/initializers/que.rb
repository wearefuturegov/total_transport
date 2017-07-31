Que.wake_interval = 10.seconds
Que.mode = (ENV['QUE_MODE'] || :sync).to_sym
Que.worker_count = (ENV['QUE_WORKERS'] || 1)
