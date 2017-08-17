module VirtDisk
  module PartitionType
    class DosPartition < Partition
      DOS_NPTE      = 4
      PTYPE_EXT_CHS = 0x05
      PTYPE_EXT_LBA = 0x0f
      PTYPE_LDM     = 0x42

      include LogDecorator::Logging
      include ExportMethods

      def initialize(disk, ptype, pnum, start_lba, size_in_blocks)
        # Convert partition size to partition end LBA.
        super(disk, ptype, pnum, start_lba, start_lba + size_in_blocks)
      end

      def self.discover_partitions(disk) # rubocop:disable AbcSize
        _log.debug "<#{disk.object_id}> disk file: #{disk.file_name}" if disk.respond_to? :file_name
        mbr = disk.mod_read(0, MBR_SIZE)

        if mbr.length < MBR_SIZE
          _log.info "<#{disk.object_id}> disk does not contain a master boot record"
          return []
        end

        sig = mbr[510..511].unpack('H4')

        pt_entry = DOS_PARTITION_ENTRY.decode(mbr[DOS_PT_START, PTE_LEN])
        ptype = pt_entry[:ptype]

        return [] if sig[0] != DOS_SIG || ptype == GPT_SIG
        discover_dos_pri_partitions(disk, mbr)
      end

      def self.discover_dos_pri_partitions(disk, mbr) # rubocop:disable AbcSize
        pte = DOS_PT_START
        partitions = []
        (1..DOS_NPTE).each do |n|
          pt_entry = DOS_PARTITION_ENTRY.decode(mbr[pte, PTE_LEN])
          pte += PTE_LEN
          ptype = pt_entry[:ptype]

          #
          # If this os an LDM (dynamic) disk, then ignore any partitions.
          #
          if ptype == PTYPE_LDM
            _log.debug "<#{disk.object_id}> detected LDM (dynamic) disk"
            return([])
          end

          if ptype == PTYPE_EXT_CHS || ptype == PTYPE_EXT_LBA
            partitions.concat(
              discover_dos_ext_partitions(
                disk,
                pt_entry[:start_lba],
                pt_entry[:start_lba],
                DOS_NPTE + 1
              )
            )
            next
          end
          partitions.push(new(disk, ptype, n, pt_entry[:start_lba], pt_entry[:part_size])) if ptype != 0
        end
        partitions
      end

      #
      # Discover secondary file system partitions within a primary extended partition.
      #
      # pri_base_lba is the LBA of the primary extended partition.
      #     All pointers to secondary extended partitions are relative to this base.
      #
      # ptBaseLBA is the LBA of the partition table within the current extended partition.
      #     All pointers to secondary file system partitions are relative to this base.
      #
      def self.discover_dos_ext_partitions(disk, pri_base_lba, ptBaseLBA, pnum) # rubocop:disable AbcSize
        ra = []
        seek(ptBaseLBA * @blockSize, IO::SEEK_SET)
        mbr = read(MBR_SIZE)

        #
        # Create and add disk object for secondary file system partition.
        # NOTE: the start of the partition is relative to ptBaseLBA.
        #
        pte = DOS_PT_START
        pt_entry = DOS_PARTITION_ENTRY.decode(mbr[pte, PTE_LEN])
        ra << new(
          disk,
          pt_entry[:ptype],
          pnum,
          pt_entry[:start_lba] + ptBaseLBA,
          pt_entry[:part_size]
        ) if pt_entry[:ptype] != 0

        #
        # Follow the chain to the next secondary extended partition.
        # NOTE: the start of the partition is relative to pri_base_lba.
        #
        pte += PTE_LEN
        pt_entry = DOS_PARTITION_ENTRY.decode(mbr[pte, PTE_LEN])
        ra.concat(
          discover_dos_ext_partitions(
            disk,
            pri_base_lba,
            pt_entry[:start_lba] + pri_base_lba,
            pnum + 1
          )
        ) if pt_entry[:start_lba] != 0
        ra
      end
    end
  end
end
