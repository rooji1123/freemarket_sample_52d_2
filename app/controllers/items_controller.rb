class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @items = Item.last(4)
    @ladies = ItemsCategory.where(category_id:"1").includes(:item)
    @mens = ItemsCategory.where(category_id:"2").includes(:item)
    @babys = ItemsCategory.where(category_id:"3").includes(:item)
    @cosme = ItemsCategory.where(category_id:"7").includes(:item)
  end

  def show
    @item = Item.find(set_item)
    @user = User.find_by(id: @item.seller_id)
    @selleritems = Item.where(seller_id: @item.seller_id).where.not(id: @item.id)
    @categoryitems = ItemsCategory.where(category_id: @item.items_categories.last.category_id).includes(:item)
    @images = @item.item_images.where(params[:item_id])
  end

  def new
    @item = Item.new
    @item.item_images.build
    @parents = Category.where(ancestry: nil).order("id ASC")
  end

  def create
    @item = Item.new(item_params)
    @parents = Category.where(ancestry: nil).order("id ASC")
    respond_to do |format|
      if @item.save && new_image_params[:images][0] != " "
        new_image_params[:images].each do |image|
          @item.item_images.create(image: image, item_id: @item.id)
        end
        format.html{redirect_to root_path}
      else
        @item.item_images.build
        format.html{render action: 'new'}
      end
    end
  end

  def edit
    @item = Item.find(set_item)
    @parents = Category.where(ancestry: nil).order("id ASC")
    @children = @item.categories[0].children
    @grand_children = @item.categories[1].children
    gon.item = @item
    gon.item_images = @item.item_images
    require 'base64'
    gon.item_images_binary_datas = []
    if Rails.env.production?
      client = Aws::S3::Client.new(
                             region: 'ap-northeast-1',
                             access_key_id: Rails.application.credentials.aws[:access_key_id],
                             secret_access_key: Rails.application.credentials.aws[:secret_access_key],
                             )
      @item.item_images.each do |image|
        binary_data = client.get_object(bucket: 'freemarket52', key: image.image.file.path).body.read
        gon.item_images_binary_datas << Base64.strict_encode64(binary_data)
      end
    else
      @item.item_images.each do |image|
        binary_data = File.read(image.image.file.file)
        gon.item_images_binary_datas << Base64.strict_encode64(binary_data)
      end
    end
  end

  def update
    @item = Item.find(set_item)
    @parents = Category.where(ancestry: nil).order("id ASC")
    @item = Item.find(params[:id])
    ids = @item.item_images.map{|image| image.id }
    exist_ids = registered_image_params[:ids].map(&:to_i)
    exist_ids.clear if exist_ids[0] == 0

    if (exist_ids.length != 0 || new_image_params[:images][0] != " ") && @item.update(item_params)
      unless ids.length == exist_ids.length
        delete_ids = ids - exist_ids
        delete_ids.each do |id|
          @item.item_images.find(id).destroy
        end
      end
      unless new_image_params[:images][0] == " "
        new_image_params[:images].each do |image|
          @item.item_images.create(image: image, item_id: @item.id)
        end
      end
      redirect_to item_path(@item), data: {turbolinks: false}
    else
      redirect_back(fallback_location: root_path)
    end

  end

  def destroy
    item = Item.find(set_item)
    item.destroy
    redirect_to root_path
  end

  def search
    @q = Item.ransack(params[:q])
    @categories = Category.where(ancestry: nil)
    @item_state = ItemState.all
    @delivery_fee = DeliveryFee.all
    @result = @q.result(distinct: true)
    @result = @result.page(params[:page]).per(20)
  end
  
  def category_search
    respond_to do |format|
      format.html
      format.json do
        if params[:parent_id]
          @children = Category.find(params[:parent_id]).children
        else
          @grand_children = Category.find(params[:child_id]).children
        end
      end
    end
  end

  def brand_search
    unless params[:keyword].nil? || params[:keyword].empty?
      @brands = Brand.where('name LIKE :name', name:"%#{params[:keyword].tr('ぁ-ん','ァ-ン')}%")
      respond_to do |format|
        format.json
      end
    end
  end

 private

  def item_params
    brand_id = params[:brand_id].to_i
    params.require(:item).permit(:name, :description, :prefecture_id, :price, :delivery_date_id, :delivery_fee_id, :delivery_choice_id, :brand_id, :item_state_id, :size_id, category_ids: []).merge(brand_id: brand_id, deal_state: 1, seller_id: current_user.id)
  end

  def set_item
    params.require(:id)
  end

  def registered_image_params
    params.require(:registered_images_ids).permit({ids: []})
  end

  def new_image_params
    params.require(:new_images).permit({images: []})
  end

end