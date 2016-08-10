require 'aws'
require 'logger'

class Upload

  S3_BUCKET_OBJECTS = AWS::S3.new({
    access_key_id: ENV.fetch('S3_KEY'),
    secret_access_key: ENV.fetch('S3_SECRET'),
  }).buckets[ENV.fetch('S3_BUCKET')].objects

  def initialize(io)
    @logger = Logger.new(STDOUT)
    @logger.formatter = proc do |severity, datetime, progname, msg|
       "[upload #{$$} #{Thread.current.object_id}] #{msg}\n"
    end
    @io = io
    @logger.info "initialized"
  end

  def generate_object_id
    Time.now.utc.strftime(ENV.fetch('STRFTIME', '%Y%m/%d/%H/%M%S.:thread_id.log').gsub(":thread_id", Thread.current.object_id.to_s))
  end

  def start
    thread = Thread.new do
      @logger.info "begin thread"
      until @io.closed?
        generate_object_id.tap do |object_id|
          @logger.info "begin #{object_id}"
          S3_BUCKET_OBJECTS[object_id].write(
            @io,
            estimated_content_length: 1 # low-ball estimate; so we can close buffer by returning nil
          )
          @logger.info "end #{object_id}"
        end
      end
      @logger.info "end thread"
    end

    at_exit do
      @logger.info "shutdown!"
      @io.close
      thread.join
    end
  end
end
