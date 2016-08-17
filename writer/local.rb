require 'fileutils'
require_relative './base.rb'

class Writer < WriterBase

  def stream_to(filepath)
    @logger.info "begin #{filepath}"
    file = "output/#{filepath}"
    FileUtils.mkdir_p File.dirname(file)
    open(file, "w") do |f|
      while data = @io.read(4068)
        f.write(data)
      end
    end
    @logger.info "end #{filepath}"
  end

end
