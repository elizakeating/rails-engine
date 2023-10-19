class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: ItemSerializer.new(Item.create(item_params)), status: :created
  end

  def update
    begin
      item = Item.find(params[:id])
      item.update(item_params)
      render json: ItemSerializer.new(item)
    rescue ActiveRecord::RecordNotFound => e
      render status: 400
    end
  end

  def destroy
    render json: Item.destroy(params[:id])
  end

  private

    def item_params
      params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
    end
end