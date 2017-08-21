module VirtDisk
  class Disk < ClientHead
    DEFAULT_BLOCK_SIZE = 512
    DISK_SIG_OFFSET    = 0x1B8
    DISK_SIG_SIZE      = 4

    def initialize(up_stream_module)
      super
    end

    def block_size
      return @up_stream_module.block_size if @up_stream_module.respond_to?(:block_size)
      DEFAULT_BLOCK_SIZE
    end
    export :block_size

    def disk_sig
      @disk_sig ||= @up_stream_module.mod_read(DISK_SIG_OFFSET, DISK_SIG_SIZE).unpack('L')[0]
    end
  end
end
