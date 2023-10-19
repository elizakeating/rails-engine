require "rails_helper"

describe "Merchants API" do
  it "sends a list of all merchants" do
    create_list(:merchant, 3)

    get "/api/v1/merchants"

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)
    
    expect(merchants[:data].count).to eq(3)
    
    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)
      
      expect(merchant[:type]).to eq("merchant")

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it "can get one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    expect(response).to be_successful

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to be_a(String)
    
    expect(merchant[:data][:type]).to eq("merchant")
    
    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to be_a(String)
  end

  it "can get the items for a given merchant ID" do
    merchant = create(:merchant)
    merchant_2 = create(:merchant)

    merchant_items = create_list(:item, 3, merchant: merchant)
    merchant_items = create_list(:item, 4, merchant: merchant_2)
    
    get "/api/v1/merchants/#{merchant.id}/items"

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].count).to eq(3)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(String)

      expect(item[:type]).to eq("item")

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_an(Integer)
    end
  end

  it "can get all merchants that match a search term" do
    merchant_1 = Merchant.create(name: "Ring World")
    merchant_2 = Merchant.create(name: "Turing")
    merchant_3 = Merchant.create(name: "Holly's Engagement Rings")
    merchant_4 = Merchant.create(name: "Ryan's Rollercoasters")

    get "/api/v1/merchants/find_all?name=rINg"

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants[:data].count).to eq(3)

    expect(merchants[:data].first[:id]).to eq("#{merchant_3.id}")
    expect(merchants[:data].first[:type]).to eq("merchant")
    expect(merchants[:data].first[:attributes][:name]).to eq("#{merchant_3.name}")

    expect(merchants[:data].last[:id]).to eq("#{merchant_2.id}")
    expect(merchants[:data].last[:type]).to eq("merchant")
    expect(merchants[:data].last[:attributes][:name]).to eq("#{merchant_2.name}")
  end
end