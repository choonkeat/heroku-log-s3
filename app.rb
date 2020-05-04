require 'logger'
require 'heroku-log-parser'
require_relative './queue_io.rb'
require_relative ENV.fetch("WRITER_LIB", "./writer/s3.rb") # provider of `Writer < WriterBase` singleton

class App

  PREFIX = ENV.fetch("FILTER_PREFIX", "")
  PREFIX_LENGTH = PREFIX.length
  LOG_REQUEST_URI = ENV['LOG_REQUEST_URI']

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.formatter = proc do |severity, datetime, progname, msg|
       "[app #{$$} #{Thread.current.object_id}] #{msg}\n"
    end
    @logger.info "initialized"
  end

  def call(env)
    lines = if LOG_REQUEST_URI
      [{ msg: env['REQUEST_URI'], ts: '' }]
    else
      HerokuLogParser.parse(env['rack.input'].read).collect { |m| { msg: m[:message], ts: m[:emitted_at].strftime('%Y-%m-%dT%H:%M:%S.%L%z') } }
    end

    lines.each do |line|
      msg = line[:msg]
      next unless msg.start_with?(PREFIX)
      Writer.instance.write([line[:ts], msg[PREFIX_LENGTH..-1]].join(' ').strip) # WRITER_LIB
    end

  rescue Exception
    @logger.error $!
    @logger.error $@

  ensure
    return [200, { 'Content-Length' => '0' }, []]
  end

end
