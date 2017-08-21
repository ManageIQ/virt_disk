require "spec_helper"
require "partition_shared_examples"

describe "DOS Partition" do
  let(:extpected_num_partitions) { 2 }
  let(:expected_partition_class) { VirtDisk::PartitionType::DosPartition }

  let(:per_partition_values) do
    [
      {
        :ptype           => 4,
        :block_size      => 512,
        :start_lba       => 63,
        :end_lba         => 575,
        :start_byte_addr => 32256,
        :end_byte_addr   => 294400,
        :size            => 262144
      },
      {
        :ptype           => 4,
        :block_size      => 512,
        :start_lba       => 575,
        :end_lba         => 2048,
        :start_byte_addr => 294400,
        :end_byte_addr   => 1048576,
        :size            => 754176
      }
    ]
  end

  data_dir = File.join(__dir__, "data")
  dos_partition_file = File.join(data_dir, "dos_partition.img")
  file_mod = VirtDisk::FileIo.new(dos_partition_file)
  disk = VirtDisk::Disk.new(file_mod)

  it "should return an array of the expected length" do
    expect(VirtDisk::PartitionType.partition_probe(disk).length).to eq(extpected_num_partitions)
  end

  VirtDisk::PartitionType.partition_probe(disk).each do |part|
    describe "Partition: #{part.pnum}" do
      before(:each) do
        @partition = part
      end

      it_should_behave_like "common_partition"
    end
  end
end
