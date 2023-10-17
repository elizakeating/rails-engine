class Api::V1::MerchantItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Merchant.find(params[:merchant_id]).items)
  end

  def show
    render json: MerchantSerializer.new(Item.find(params[:item_id]).merchant)
  end
end