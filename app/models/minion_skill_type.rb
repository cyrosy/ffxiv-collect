# == Schema Information
#
# Table name: minion_skill_types
#
#  id         :bigint(8)        not null, primary key
#  name_en    :string(255)      not null
#  name_de    :string(255)      not null
#  name_fr    :string(255)      not null
#  name_ja    :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MinionSkillType < ApplicationRecord
  translates :name
  has_many :minions
end
