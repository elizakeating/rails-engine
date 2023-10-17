class Api::V1::MerchantItemsController < ApplicationController
  def index
    render json: Merchant.find(params[:merchant_id]).items
  end

  def show
    render json: Item.find(params[:item_id]).merchant
  end
end