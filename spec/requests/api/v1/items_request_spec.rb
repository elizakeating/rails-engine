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

  it "can get an item based on id" do
    merchant = create(:merchant)
    item_id = create(:item, merchant: merchant).id

    get "/api/v1/items/#{item_id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to be_an(String)
    
    expect(item[:data][:type]).to eq("item")
    
    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to be_a(Float)

    expect(item[:data][:attributes]).to have_key(:merchant_id)
    expect(item[:data][:attributes][:merchant_id]).to be_an(Integer)
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

  it "returns an error if you try to update an item that doesn't exist" do
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/1", headers: headers, params: JSON.generate({name: "item"})

    expect(response).to_not be_successful
    expect(response.status).to eq(404)
  end

  it "returns an error if you try to update an item with a bad merchant id" do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)
    item_params = { name: "A brush for hair", merchant_id: 9999999 }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})

    expect(response).to_not be_successful
    expect(response.status).to eq(404)
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
    merchant_1 = create(:merchant)
    item = create(:item, merchant: merchant_1)

    get "/api/v1/items/#{item.id}/merchant"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to be_an(String)
    expect(merchant[:data][:id]).to eq("#{merchant_1[:id]}")
    
    expect(merchant[:data][:type]).to eq("merchant")

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to be_a(String)
    expect(merchant[:data][:attributes][:name]).to eq(merchant_1[:name])
  end

  it "can get one item based on a case-insensitive search, based on alphabetical ordered, name query parameter" do
    merchant = create(:merchant)
    item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: merchant.id)
    item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: merchant.id)
    item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: merchant.id)
    item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: merchant.id)
    item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: merchant.id)

    get "/api/v1/items/find?name=bRu"

    expect(response).to be_successful

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data][:id]).to eq("#{item_1.id}")
    expect(item[:data][:type]).to eq("item")
    expect(item[:data][:attributes][:name]).to eq(item_1.name)
    expect(item[:data][:attributes][:description]).to eq(item_1.description)
    expect(item[:data][:attributes][:unit_price]).to eq(item_1.unit_price)
  end

  it "can get first item sorted alphabeticaly higher than the min price searched" do
    merchant = create(:merchant)
    item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: merchant.id)
    item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: merchant.id)
    item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: merchant.id)
    item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: merchant.id)
    item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: merchant.id)

    get "/api/v1/items/find?min_price=14.25"

    expect(response).to be_successful

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data][:id]).to eq("#{item_5.id}")
    expect(item[:data][:type]).to eq("item")
    expect(item[:data][:attributes][:name]).to eq(item_5.name)
    expect(item[:data][:attributes][:description]).to eq(item_5.description)
    expect(item[:data][:attributes][:unit_price]).to eq(item_5.unit_price)
  end

  it "can get first item sorted alphabeticaly less than the max price searched" do
    merchant = create(:merchant)
    item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: merchant.id)
    item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: merchant.id)
    item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: merchant.id)
    item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: merchant.id)
    item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: merchant.id)

    get "/api/v1/items/find?max_price=14.25"

    expect(response).to be_successful

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data][:id]).to eq("#{item_1.id}")
    expect(item[:data][:type]).to eq("item")
    expect(item[:data][:attributes][:name]).to eq(item_1.name)
    expect(item[:data][:attributes][:description]).to eq(item_1.description)
    expect(item[:data][:attributes][:unit_price]).to eq(item_1.unit_price)
  end

  it "can get first item sorted alphabeticaly more than the min price AND less than the max price searched" do
    merchant = create(:merchant)
    item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: merchant.id)
    item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: merchant.id)
    item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: merchant.id)
    item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: merchant.id)
    item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: merchant.id)

    get "/api/v1/items/find?min_price=10.00&max_price=24.00"

    expect(response).to be_successful

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data][:id]).to eq("#{item_3.id}")
    expect(item[:data][:type]).to eq("item")
    expect(item[:data][:attributes][:name]).to eq(item_3.name)
    expect(item[:data][:attributes][:description]).to eq(item_3.description)
    expect(item[:data][:attributes][:unit_price]).to eq(item_3.unit_price)
  end

  it "gives an error if you try to find item with both name and price" do
    merchant = create(:merchant)
    item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: merchant.id)
    item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: merchant.id)
    item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: merchant.id)
    item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: merchant.id)
    item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: merchant.id)

    get "/api/v1/items/find?name=bRu&max_price=24.00"

    expect(response).to_not be_successful
    expect(response.status).to eq(400)
  end

  it "gives an error if you try to find put a price less than 0" do
    merchant = create(:merchant)
    item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: merchant.id)
    item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: merchant.id)
    item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: merchant.id)
    item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: merchant.id)
    item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: merchant.id)

    get "/api/v1/items/find?min_price=-2.00"

    expect(response).to_not be_successful
    expect(response.status).to eq(400)

    error = JSON.parse(response.body, symbolize_names: true)

    expect(error[:errors].count).to eq(1)
    expect(error[:errors].first).to eq("minimum price less than 0")
  end

  it "gives an error if you try to find put a price less than 0" do
    merchant = create(:merchant)
    item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: merchant.id)
    item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: merchant.id)
    item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: merchant.id)
    item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: merchant.id)
    item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: merchant.id)

    get "/api/v1/items/find?max_price=-2.00"

    expect(response).to_not be_successful
    expect(response.status).to eq(400)

    error = JSON.parse(response.body, symbolize_names: true)

    expect(error[:errors].count).to eq(1)
    expect(error[:errors].first).to eq("maximum price less than 0")
  end

  it "gives an object with null values if no object matches for all item searches" do
    merchant = create(:merchant)
    item_1 = Item.create!(name: "Hairbrush", description: "a brush to brush your hair", unit_price: 4.99, merchant_id: merchant.id)
    item_2 = Item.create!(name: "Toothbrush", description: "a brush to brush your teeth", unit_price: 10.99, merchant_id: merchant.id)
    item_3 = Item.create!(name: "How to utilize your brush", description: "a book about utilizing many brushes", unit_price: 15.99, merchant_id: merchant.id)
    item_4 = Item.create!(name: "Paintbrush", description: "a brush to paint with", unit_price: 20.00, merchant_id: merchant.id)
    item_5 = Item.create!(name: "hat", description: "wear on your head", unit_price: 25.00, merchant_id: merchant.id)

    get "/api/v1/items/find?name=CAT"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data][:id]).to eq(nil)
    
    get "/api/v1/items/find?max_price=3.00"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data][:id]).to eq(nil)
    
    get "/api/v1/items/find?min_price=26.00"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data][:id]).to eq(nil)
    
    get "/api/v1/items/find?min_price=1.00&max_price=2.00"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(item[:data][:id]).to eq(nil)
  end
end