require 'spec_helper'

describe Reply do
  before do
    @reply  = create(:reply)
  end

  it { should respond_to(:note_id) }
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }

  it { should be_valid }
end
