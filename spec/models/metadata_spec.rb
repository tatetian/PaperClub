require 'spec_helper'

describe Metadata do
  before do
    @paper1 = create(:paper)
    @paper2 = create(:paper)

    @metadata = create(:metadata, uuid: @paper1.uuid)
  end

  subject { @metadata }

  it { should respond_to(:num_pages) }
  it { should respond_to(:pub_date) }
  it { should respond_to(:uuid) }
  it { should respond_to(:title) }

  it { should be_valid }

  it "has two associated papers" do
    @metadata.paper_count.should == 2
  end

  it "will be removed when no associated papers" do
    @paper1.destroy
    @metadata.reload
    @paper2.destroy
    expect {
      @metadata.reload
    }.to raise_error
  end

  it "is used by papers" do
    @metadata.used?.should == true
  end
end
