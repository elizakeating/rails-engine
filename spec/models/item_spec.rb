require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :merchant_id }
  end

  describe "relationships" do
    it { should belong_to :merchant }
  end

  before(:each) do
    @merchant = create(:merchant)
    @item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: @merchant.id)
    @item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: @merchant.id)
    @item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: @merchant.id)
    @item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: @merchant.id)
    @item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: @merchant.id)
  end

  describe "class methods" do
    describe ".max_price" do
      it "returns a single item that is less than the max price" do
        item = Item.max_price(14.25)

        expect(item.id).to eq(@item_1.id)
        expect(item.name).to eq(@item_1.name)
        expect(item.description).to eq(@item_1.description)
        expect(item.unit_price).to eq(@item_1.unit_price)
      end
    end

    describe ".min_price" do
      it "returns a single item that is more than the min price and less than the max price" do
        item = Item.min_price(14.25)

        expect(item.id).to eq(@item_5.id)
        expect(item.name).to eq(@item_5.name)
        expect(item.description).to eq(@item_5.description)
        expect(item.unit_price).to eq(@item_5.unit_price)
      end
    end

    describe ".min_and_max" do
      it "returns a single item that is less than the max price" do
        item = Item.min_and_max(10.00, 24.00)

        expect(item.id).to eq(@item_3.id)
        expect(item.name).to eq(@item_3.name)
        expect(item.description).to eq(@item_3.description)
        expect(item.unit_price).to eq(@item_3.unit_price)
      end
    end

    describe ".find_name" do
      it "returns a single item that is based off a case insensitive search" do
        item = Item.find_name("bRu")

        expect(item.id).to eq(@item_1.id)
        expect(item.name).to eq(@item_1.name)
        expect(item.description).to eq(@item_1.description)
        expect(item.unit_price).to eq(@item_1.unit_price)
      end
    end
  end
end
