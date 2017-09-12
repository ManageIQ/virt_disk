module VirtDisk
  class ClientHead
    attr_reader :size, :start_byte_addr, :end_byte_addr, :seek_pos

    include ExportMethods

    def initialize(up_stream_module)
      @up_stream_module = up_stream_module
      @start_byte_addr  = 0
      @size             = @up_stream_module.size
      @end_byte_addr    = @size - 1
      @seek_pos         = @start_byte_addr
      self.delegate     = @up_stream_module
    end

    def close
      @up_stream_module.close
    end

    def seek_pos
      @seek_pos - @start_byte_addr
    end

    def seek(amt, whence = IO::SEEK_SET)
      case whence
      when IO::SEEK_CUR
        @seek_pos += amt
      when IO::SEEK_END
        @seek_pos = @endByteAddr + amt
      when IO::SEEK_SET
        @seek_pos = amt + @start_byte_addr
      end
      @seek_pos
    end

    def read(len)
      rb = mod_read(@seek_pos, len)
      @seek_pos += rb.length unless rb.nil?
      rb
    end

    def write(buf, len)
      nbytes = @up_stream_module.mod_write(@seek_pos, buf, len)
      @seek_pos += nbytes
      nbytes
    end

    def mod_read(offset, len)
      @up_stream_module.mod_read(offset, len)
    end

    def mod_write(offset, buffer, len)
      @up_stream_module.mod_write(offset, buffer, len)
    end
  end
end
