module VirtDisk
  class BlockFile
    attr_accessor :path

    def initialize(path)
      @path = path
      @file = File.open(path)
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
      @file.seek start
      @file.read len
    end

    def raw_write(buf, start, len)
      @file.seek start
      @file.write buf, len
    end
  end # class BlockFile
end # module VirtDisk
