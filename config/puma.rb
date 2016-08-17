workers_count = Integer(ENV.fetch("WEB_CONCURRENCY", 1))
workers(workers_count)

threads_count = Integer(ENV.fetch("WEB_MAX_THREADS", 25))
threads(threads_count, threads_count)

port ENV.fetch("PORT", 9292)
environment ENV.fetch("RACK_ENV", "development")
