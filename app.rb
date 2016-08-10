require 'logger'
require 'heroku-log-parser'

class App

  PREFIX = ENV.fetch("FILTER_PREFIX")
  PREFIX_LENGTH = PREFIX.length

  def initialize(io)
    @logger = Logger.new(STDOUT)
    @logger.formatter = proc do |severity, datetime, progname, msg|
       "[app #{$$} #{Thread.current.object_id}] #{msg}\n"
    end
    @io = io
    @logger.info "initialized"
  end

  def call(env)
    req = Rack::Request.new(env)
    line = env['rack.input'].read

    HerokuLogParser.parse(line).each do |m|
      next unless m[:message].start_with?(PREFIX)
      @io.write(m[:message][PREFIX_LENGTH..-1] + "\n")
    end

  rescue Exception
    @logger.error $!
    @logger.error $@

  ensure
    return [200, { 'Content-Length' => '0' }, []]
  end

end
