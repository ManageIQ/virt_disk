module VirtDisk
  class FileIo
    attr_accessor :path
    alias_method :file_name, :path

    include LogDecorator::Logging
    include ExportMethods

    export :path, :file_name

    def initialize(path, *args)
      @path      = path
      @file_lock = Mutex.new

      _log.debug "Opening file - #{path}"
      @file = File.open(path, *args)
    end

    def size
      @file.size
    end

    def close
      @file.close
    end

    def mod_read(start, len)
      @file_lock.synchronize do
        @file.seek start
        @file.read len
      end
    end

    def mod_write(buf, start, len)
      @file_lock.synchronize do
        @file.seek start
        @file.write buf, len
      end
    end
  end
end
