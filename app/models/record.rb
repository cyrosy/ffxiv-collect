# == Schema Information
#
# Table name: records
#
#  id               :bigint(8)        not null, primary key
#  name_en          :string(255)      not null
#  name_de          :string(255)      not null
#  name_fr          :string(255)      not null
#  name_ja          :string(255)      not null
#  description_en   :text(65535)      not null
#  description_de   :text(65535)      not null
#  description_fr   :text(65535)      not null
#  description_ja   :text(65535)      not null
#  rarity           :integer          not null
#  patch            :string(255)
#  linked_record_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  location         :string(255)
#
class Record < ApplicationRecord
  include Collectable

  belongs_to :linked_record, class_name: 'Record', optional: true
  translates :name, :description

  scope :include_related, -> { include_sources }
  scope :ordered, -> { order(:id) }
end
