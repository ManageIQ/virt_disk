module VirtDisk
  class BlockFile
    attr_accessor :path, :offset

    def initialize(path, offset=0)
      @path = path
      @offset = offset
      @file = defined?(VirtFS) ? VirtFS::VFile.open(path) : File.open(path)
    end

    def block_size
      1
    end

    def size
      @file.size
    end

    def close
      @file.close
    end

    def raw_read(start, len)
      @file.seek start + offset
      @file.read len
    end

    def raw_write(buf, start, len)
      @file.seek start + offset
      @file.write buf, len
    end
  end # class BlockFile
end # module VirtDisk
