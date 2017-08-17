require 'uuidtools'

module VirtDisk
  module PartitionType
    class GptPartition < Partition
      GPT_HEADER = BinaryStruct.new([
        'a8',    :signature,    # 00-07: Signature "EFI PART"
        'a4',    :version,      # 08-11: Revision
        'L',     :header_size,  # 12-15: Header size
        'L',     :crc32_header, # 16-19:
        'L',     :reserved,     # 20-23:
        'Q',     :cur_lba,      # 24-31:
        'Q',     :bak_lba,      # 32-39:
        'Q',     :first_lba,    # 40-47:
        'Q',     :last_lba,     # 48-55:
        'a16',   :guid,         # 56-71:
        'Q',     :startLBA,     # 72-79:
        'L',     :part_num,     # 80-83:
        'L',     :part_size,    # 84-87:
        'L',     :part_array,   # 88-91:
        'a420',  :reserved2,    # 92-511:
      ])

      GPT_PARTITION_ENTRY = BinaryStruct.new([
        'a16',   :ptype,      # 00-15: partition type
        'a16',   :pguid,      # 16-31: partition GUID
        'Q',     :first_lba,  # 32-39: first LBA
        'Q',     :last_lba,   # 40-47: last LBA
        'a8',    :attr_flag,  # 48-55: attribute flag
        'a72',   :pname,      # 56-127: partition name
      ])

      include LogDecorator::Logging
      include ExportMethods

      def self.discover_partitions(disk) # rubocop:disable AbcSize
        mbr = disk.mod_read(0, MBR_SIZE)
        if mbr.length < MBR_SIZE
          _log.info "<#{disk.object_id}> disk does not contain a master boot record"
          return []
        end

        sig = mbr[510..511].unpack('H4')

        pt_entry = DOS_PARTITION_ENTRY.decode(mbr[DOS_PT_START, PTE_LEN])
        ptype = pt_entry[:ptype]

        return [] if sig[0] != DOS_SIG || ptype != GPT_SIG
        discover_gpt_partitions(disk)
      end

      def self.discover_gpt_partitions(disk) # rubocop:disable AbcSize
        _log.info "Parsing GPT disk ..."
        gpt_header = disk.mod_read(MBR_SIZE, GPT_HEADER.size)
        header = GPT_HEADER.decode(gpt_header)

        partitions = []
        pte = GPT_HEADER.size + MBR_SIZE
        (1..header[:part_num]).each do |n|
          gpt = disk.mod_read(pte, GPT_PARTITION_ENTRY.size)
          pt_entry = GPT_PARTITION_ENTRY.decode(gpt)
          ptype = UUIDTools::UUID.parse_raw(pt_entry[:ptype]).to_s

          partitions.push(new(disk, ptype, n, pt_entry[:first_lba], pt_entry[:last_lba])) if pt_entry[:first_lba] != 0
          pte += header[:part_size]
        end
        partitions
      end
    end
  end
end
