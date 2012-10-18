class StatisticsController < ApplicationController
	def index
	end

	def statistic
		days = (params[:days] || 30).to_i
		render :json => {
      :type => 'LineChart',
      :cols => [['string', 'Date'], ['number', 'Users'], ['number', 'Clubs'], ['number', 'Unique Papers']],
      :rows => (1..days).to_a.inject([]) do |memo, i|
        date = i.days.ago.to_date
        t0, t1 = date.beginning_of_day, date.end_of_day
        users = User.where{created_at >= t0 and created_at < t1}.count
        clubs = Club.where{created_at >= t0 and created_at < t1}.count
        papers = Metadata.where{created_at >= t0 and created_at < t1}.count
        memo << [date, users, clubs, papers]
        memo
      end.reverse,
      :options => {
        :chartArea => { :width => '90%', :height => '75%' },
        :hAxis => { :showTextEvery => 30 },
        :legend => 'bottom',
        :title => 'Overview of PaperClub(in the last 30 days)'
      }
    }
	end
end
