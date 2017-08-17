shared_examples_for "common_partition" do
  it "should be of expected data type" do
    expect(@partition).to be_kind_of(expected_partition_class)
  end

  it "should have the expected 'ptype' value" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.ptype).to eq(pvalues[:ptype])
  end

  it "should have the expected 'block_size' value" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.block_size).to eq(pvalues[:block_size])
  end

  it "should have the expected 'start_lba' value" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.start_lba).to eq(pvalues[:start_lba])
  end

  it "should have the expected 'end_lba' value" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.end_lba).to eq(pvalues[:end_lba])
  end

  it "should have the expected 'start_byte_addr' value" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.start_byte_addr).to eq(pvalues[:start_byte_addr])
  end

  it "should have the expected 'end_byte_addr' value" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.end_byte_addr).to eq(pvalues[:end_byte_addr])
  end

  it "should have the expected 'size' value" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.size).to eq(pvalues[:size])
  end

  it "'start_byte_addr' should be consistent with 'start_lba' and 'block_size'" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.start_byte_addr).to eq(@partition.start_lba * @partition.block_size)
  end

  it "'end_byte_addr' should be consistent with 'end_lba' and 'block_size'" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.end_byte_addr).to eq(@partition.end_lba * @partition.block_size)
  end

  it "'size' should be consistent with 'start_byte_addr' and 'end_byte_addr'" do
    pvalues = per_partition_values[@partition.pnum - 1]
    expect(@partition.size).to eq(@partition.end_byte_addr - @partition.start_byte_addr)
  end
end
