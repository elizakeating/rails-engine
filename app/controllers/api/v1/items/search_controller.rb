class Api::V1::Items::SearchController < ApplicationController
  def show
    if (!params[:min_price].nil? && !params[:name].nil?) || (!params[:max_price].nil? && !params[:name].nil?)
      render status: 400
    elsif !params[:name].nil?
      query = params[:name]

      item = Item.find_name(query)
      
      render json: ItemSerializer.new(item)
    elsif !params[:min_price].nil? && !params[:max_price].nil?
      max_price = params[:max_price]
      min_price = params[:min_price]

      item = Item.min_and_max(min_price, max_price)

      render json: ItemSerializer.new(item)
    elsif !params[:min_price].nil?
      query = params[:min_price]

      if query.to_f < 0.00
        render json: { errors: ["minimum price less than 0"]}, status: 400
      else
        item = Item.min_price(query)

        render json: ItemSerializer.new(item)
      end
    elsif !params[:max_price].nil?
      query = params[:max_price]

      if query.to_f < 0.00
        render json: { errors: ["maximum price less than 0"]}, status: 400
      else
        item = Item.max_price(query)
        render json: ItemSerializer.new(item)
      end
    end
  end
end