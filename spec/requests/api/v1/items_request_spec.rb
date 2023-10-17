require "rails_helper"

describe "Items API" do
  it "sends a list of all items" do
    merchant_1 = create(:merchant)
    merchant_2 = create(:merchant)
    create_list(:item, 5, merchant: merchant_1)
    create_list(:item, 3, merchant: merchant_2)

    get "/api/v1/items"

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].count).to eq(8)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(String)

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

  it "can get an item based on id" do
    merchant = create(:merchant)
    item_id = create(:item, merchant: merchant).id

    get "/api/v1/items/#{item_id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item).to have_key(:id)
    expect(item[:id]).to be_an(Integer)

    expect(item).to have_key(:name)
    expect(item[:name]).to be_a(String)

    expect(item).to have_key(:description)
    expect(item[:description]).to be_a(String)

    expect(item).to have_key(:unit_price)
    expect(item[:unit_price]).to be_a(Float)

    expect(item).to have_key(:merchant_id)
    expect(item[:merchant_id]).to be_an(Integer)
  end
  
  it "can create a new item" do
    merchant_id = create(:merchant).id
    item_params = ({
                    name: "Hairbrush",
                    description: "Used to brush your hair",
                    unit_price: 374.23,
                    merchant_id: merchant_id
                  })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "can update an exisiting item" do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)
    previous_name = Item.last.name
    item_params = { name: "A brush for hair" }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: item.id)

    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("A brush for hair")
  end

  it "can destroy an item" do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)

    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can get the merchant data for a given item ID" do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)

    get "/api/v1/items/#{item.id}/merchant"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant).to have_key(:id)
    expect(merchant[:id]).to be_an(Integer)
    expect(merchant[:id]).to eq(merchant[:id])

    expect(merchant).to have_key(:name)
    expect(merchant[:name]).to be_a(String)
    expect(merchant[:name]).to eq(merchant[:name])
  end
end