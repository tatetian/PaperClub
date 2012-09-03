require 'spec_helper'

describe News do
  before do
    @user = create(:user)
    @paper = create(:paper, uploader_id: @user.id)
    @news = News.find_by_paper_id(@paper.id)
  end

  subject { @news }

  it { should respond_to(:action) }
  it { should respond_to(:detail) }
  it { should respond_to(:paper_id) }
  it { should respond_to(:user_id) }

  it { should be_valid }

  it "renders json" do
    puts @news.to_json
  end
end
