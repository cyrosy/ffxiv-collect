# == Schema Information
#
# Table name: tomestone_rewards
#
#  id               :bigint(8)        not null, primary key
#  cost             :integer
#  collectable_id   :integer
#  collectable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  tomestone        :string(255)
#

class TomestoneReward < ApplicationRecord
  belongs_to :collectable, polymorphic: true

  scope :collectable, -> { where.not(collectable_type: 'Item') }
  scope :include_related, -> { includes(collectable: { sources: [:type, :related] }) }
  scope :items, -> { where(collectable_type: 'Item') }
  scope :ordered, -> { order(cost: :desc) }
end
