require 'spec_helper'

describe Note do
  before do
    @note = create(:note)
  end

  subject { @note }

  it { should respond_to(:content) }
  it { should respond_to(:position) }
  it { should respond_to(:user_id) }
  it { should respond_to(:paper_id) }
end
