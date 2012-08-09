require 'spec_helper'

describe Collection do
  before do
    @collection = create(:collection)
  end

  subject { @collection }

  it { should respond_to(:paper_id) }
  it { should respond_to(:tag_id) }

  it { should be_valid }
end
