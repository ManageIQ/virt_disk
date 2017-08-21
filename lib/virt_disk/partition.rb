require "binary_struct"

module VirtDisk
  class Partition < ClientHead
    attr_reader :start_lba, :end_lba, :ptype, :pnum

    MBR_SIZE = 512
    DOS_SIG  = "55aa"
    GPT_SIG  = 238

    DOS_PARTITION_ENTRY = BinaryStruct.new([
      'C', :bootable,
      'C', :startCHS0,
      'C', :startCHS1,
      'C', :startCHS2,
      'C', :ptype,
      'C', :endCHS0,
      'C', :endCHS1,
      'C', :endCHS1,
      'L', :start_lba,
      'L', :part_size
    ])
    PTE_LEN      = DOS_PARTITION_ENTRY.size
    DOS_PT_START = 446

    def initialize(disk, ptype, pnum, start_lba, end_lba)
      super(disk)

      @start_lba        = start_lba
      @end_lba          = end_lba
      @ptype            = ptype
      @pnum             = pnum
      @start_byte_addr  = @start_lba * block_size
      @end_byte_addr    = @end_lba * block_size
      @seek_pos         = @start_byte_addr
      @size             = @end_byte_addr - @start_byte_addr
    end
  end
end
