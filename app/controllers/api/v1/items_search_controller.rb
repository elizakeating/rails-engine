class Api::V1::ItemsSearchController < ApplicationController
  def show
    if !params[:name].nil?
      query = params[:name]

      item = Item.where("lower(name) like lower('%#{query}%')").order("lower(name)").first
    
      render json: ItemSerializer.new(item)
    elsif !params[:min_price].nil? 
      query = params[:min_price]

      item = Item.where("unit_price >= ?", query).order("lower(name)").first

      render json: ItemSerializer.new(item)
    elsif !params[:max_price].nil?
      query = params[:max_price]

      item = Item.where("unit_price <= ?", query).order("lower(name)").first

      render json: ItemSerializer.new(item)
    end
  end
end