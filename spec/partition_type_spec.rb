require "spec_helper"

describe VirtDisk::PartitionType do
  let(:data_dir) do
    File.join(__dir__, "data")
  end

  let(:dos_partition_file) do
    File.join(data_dir, "dos_partition.img")
  end

  let(:no_partition_file) do
    File.join(data_dir, "no_partition.img")
  end

  describe "partition_types" do
    it "should return an array" do
      expect(VirtDisk::PartitionType.partition_types).to be_kind_of(Array)
    end

    it "should return an array of the expected length" do
      expect(VirtDisk::PartitionType.partition_types.length).to eq(2)
    end

    it "should return an array with the expected data" do
      expect(VirtDisk::PartitionType.partition_types)
        .to match_array([VirtDisk::PartitionType::DosPartition, VirtDisk::PartitionType::GptPartition])
    end
  end

  describe "partition_probe" do
    describe "unpartitioned disk" do
      before(:each) do
        file_mod = VirtDisk::FileIo.new(no_partition_file)
        @disk = VirtDisk::Disk.new(file_mod)
      end

      after(:each) do
        @disk.close
      end

      it "should return an array" do
        expect(VirtDisk::PartitionType.partition_probe(@disk)).to be_kind_of(Array)
      end

      it "should return an empty array" do
        expect(VirtDisk::PartitionType.partition_probe(@disk).length).to eq(0)
      end
    end

    describe "partitioned disk" do
      before(:each) do
        file_mod = VirtDisk::FileIo.new(dos_partition_file)
        @disk = VirtDisk::Disk.new(file_mod)
      end

      after(:each) do
        @disk.close
      end

      it "should return an array" do
        expect(VirtDisk::PartitionType.partition_probe(@disk)).to be_kind_of(Array)
      end

      it "should return an array of the expected length" do
        expect(VirtDisk::PartitionType.partition_probe(@disk).length).to eq(2)
      end

      it "should return an array with the expected data" do
        expect(VirtDisk::PartitionType.partition_probe(@disk).first).to be_kind_of(VirtDisk::PartitionType::DosPartition)
      end
    end
  end
end
