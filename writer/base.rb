require 'singleton'
require 'logger'
require_relative '../queue_io.rb'

class WriterBase
  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.formatter = proc do |severity, datetime, progname, msg|
       "[upload #{$$} #{Thread.current.object_id}] #{msg}\n"
    end
    @io = QueueIO.new
    @logger.info "initialized"
    self.start
  end

  def write(line)
    @io.write(line + "\n")
  end

  def generate_filepath
    Time.now.utc.strftime(ENV.fetch('STRFTIME', '%Y%m/%d/%H/%M%S.:thread_id.log').gsub(":thread_id", Thread.current.object_id.to_s))
  end

  def stream_to(filepath)
    raise NotImplementedError.new("stream_to(filepath)")
  end

  def start
    thread = Thread.new do
      @logger.info "begin thread"
      stream_to(generate_filepath) until @io.closed?
      @logger.info "end thread"
    end

    at_exit do
      @logger.info "shutdown!"
      @io.close
      thread.join
    end
  end
end
