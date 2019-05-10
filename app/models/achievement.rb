# == Schema Information
#
# Table name: achievements
#
#  id             :bigint(8)        not null, primary key
#  name_en        :string(255)      not null
#  name_de        :string(255)      not null
#  name_fr        :string(255)      not null
#  name_ja        :string(255)      not null
#  description_en :string(255)      not null
#  description_de :string(255)      not null
#  description_fr :string(255)      not null
#  description_ja :string(255)      not null
#  points         :integer          not null
#  order          :integer          not null
#  patch          :string(255)
#  category_id    :integer          not null
#  title_en       :string(255)
#  title_de       :string(255)
#  title_fr       :string(255)
#  title_ja       :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  item_id        :integer
#  item_name_en   :string(255)
#  item_name_de   :string(255)
#  item_name_fr   :string(255)
#  item_name_ja   :string(255)
#

class Achievement < ApplicationRecord
  belongs_to :category, class_name: 'AchievementCategory'
  delegate :type, to: :category
  translates :name, :description, :title, :item_name
end