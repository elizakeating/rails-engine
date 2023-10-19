class Api::V1::ItemsSearchController < ApplicationController
  def show
    if (!params[:min_price].nil? && !params[:name].nil?) || (!params[:max_price].nil? && !params[:name].nil?)
      render status: 400
    elsif !params[:name].nil?
      query = params[:name]

      item = Item.where("lower(name) like lower('%#{query}%')").order("lower(name)").first
    
      render json: ItemSerializer.new(item)
    elsif !params[:min_price].nil? && !params[:max_price].nil?
      max_price = params[:max_price]
      min_price = params[:min_price]

      item = Item.where("unit_price >= ? AND unit_price <= ?", min_price, max_price).order("lower(name)").first

      render json: ItemSerializer.new(item)
    elsif !params[:min_price].nil?
      query = params[:min_price]

      if query.to_f < 0.00
        render json: { errors: ["minimum price less than 0"]}, status: 400
      else
        item = Item.where("unit_price >= ?", query).order("lower(name)").first

        render json: ItemSerializer.new(item)
      end
    elsif !params[:max_price].nil?
      query = params[:max_price]

      item = Item.where("unit_price <= ?", query).order("lower(name)").first

      render json: ItemSerializer.new(item)
    end
  end
end