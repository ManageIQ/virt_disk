require "spec_helper"
require "partition_shared_examples"

describe "GPT Partition" do
  let(:extpected_num_partitions) { 3 }
  let(:expected_partition_class) { VirtDisk::PartitionType::GptPartition }

  let(:per_partition_values) do
    [
      {
        :ptype           =>  "af3dc60f-8384-7247-8e79-3d69d8477de4",
        :block_size      => 512,
        :start_lba       => 34,
        :end_lba         => 512,
        :start_byte_addr => 17408,
        :end_byte_addr   => 262144,
        :size            => 244736
      },
      {
        :ptype           => "af3dc60f-8384-7247-8e79-3d69d8477de4",
        :block_size      => 512,
        :start_lba       => 513,
        :end_lba         => 1024,
        :start_byte_addr => 262656,
        :end_byte_addr   => 524288,
        :size            => 261632
      },
      {
        :ptype           => "af3dc60f-8384-7247-8e79-3d69d8477de4",
        :block_size      => 512,
        :start_lba       => 1025,
        :end_lba         => 2014,
        :start_byte_addr => 524800,
        :end_byte_addr   => 1031168,
        :size            => 506368
      }
    ]
  end

  data_dir = File.join(__dir__, "data")
  dos_partition_file = File.join(data_dir, "gpt_partition.img")
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
