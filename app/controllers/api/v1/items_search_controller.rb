class Api::V1::ItemsSearchController < ApplicationController
  def show
    query = params[:name]

    item = Item.where("lower(name) like lower('%#{query}%')").order("name").first
    
    render json: ItemSerializer.new(item)
  end
end