require 'logger'

class QueueIO
  def initialize(duration = Integer(ENV.fetch('DURATION', 60)))
    @duration = duration
    @pending = Queue.new
    @queue = Queue.new
    @start = Time.now.to_i
  end

  def write(data)
    @queue.push(data)
  end

  def read(bytes)
    return if @closed
    @pending.pop(true) # non-blocking, best effort

  rescue Exception
    @pending.push @queue.shift
    now = Time.now.to_i
    if (@start + @duration) < now
      @start = now
      return # make `eof?` return true
    else
      return @pending.shift
    end
  end

  def eof?
    !@pending.empty?
  end

  def close
    # make `closed?` return true
    @closed = true

    # short circuit `:read`
    @duration = 0
    @queue.push ""
    @queue.push ""
  end

  def closed?
    @closed
  end
end
