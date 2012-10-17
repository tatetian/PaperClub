class AddExtentionToAllAvarterUrl < ActiveRecord::Migration
  def change
    User.all.each { |u|
      if File.extname(u.avatar_url).empty?
        u.update_attribute(:avatar_url, u.avatar_url+ ".png")
      end
    }
  end
end
