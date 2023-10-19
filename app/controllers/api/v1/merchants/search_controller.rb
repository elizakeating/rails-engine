class Api::V1::Merchants::SearchController < ApplicationController
  def show
    query = params[:name]

    merchants = Merchant.where("lower(name) like lower('%#{query}%')").order("name")

    render json: MerchantSerializer.new(merchants)
  end
end