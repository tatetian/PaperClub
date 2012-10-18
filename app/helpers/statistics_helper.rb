module StatisticsHelper
  def chart_tag (action, height, params = {})
  	params[:format] ||= :json
  	path = statistics_path(action, params)
  	content_tag(:div, :'data-chart' => path, :style => "height: #{height}px;") do
    	image_tag('loading.gif', :class => 'spinner')
    end
  end
end