require 'aws'
require 'logger'
require_relative './base.rb'

class Writer < WriterBase

  S3_BUCKET_OBJECTS = AWS::S3.new({
    access_key_id: ENV.fetch('S3_KEY'),
    secret_access_key: ENV.fetch('S3_SECRET'),
  }).buckets[ENV.fetch('S3_BUCKET')].objects

  def stream_to(filepath)
    @logger.info "begin #{filepath}"
    S3_BUCKET_OBJECTS[filepath].write(
      @io,
      estimated_content_length: 1 # low-ball estimate; so we can close buffer by returning nil
    )
    @logger.info "end #{filepath}"
  end

end
