class Item < ApplicationRecord
  belongs_to :merchant

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true
  validates :merchant_id, presence: true

  def self.max_price(query)
    item = Item.where("unit_price <= ?", query).order("lower(name)").first

    if item.nil?
      item = Item.new
    else
      item
    end
  end
end
