module VirtDisk
  module PartitionType
    def self.partition_probe(disk)
      partition_types.each do |partition_type|
        partitions = partition_type.discover_partitions(disk)
        return partitions unless partitions.empty?
      end
      []
    end

    def self.partition_types
      constants.collect { |sym| const_get(sym) }
        .find_all { |obj| obj.is_a?(Class) && obj.respond_to?(:discover_partitions) }
    end
  end
end
