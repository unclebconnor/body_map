class MapsController < ApplicationController
   def index
    @maps = current_user.maps.all
  end

  def create
  	@user = current_user
    @user.maps.create(map_params)
    redirect_to user_path(@user.id)
  end

  def new
    @map = Map.new
    @widgets = Widget.all
  end

  def edit
    @map = Map.find(params[:id])
    @widgetInfo = Widget.find_by name: @map.bodySystem
    @widgetSelected =@widgetInfo.name
    @widgetId = @widgetInfo.contentId
    @organs = Organ.where(:widget_id => @widgetInfo.id)
    @organs = @organs.order(:id)
    @annotations = @map.annotations.all
  end

  def show
    @map = Map.find(params[:id])
    @widgetInfo = Widget.find_by name: @map.bodySystem
    @widgetContentId = @widgetInfo.contentId
    gon.organs = Organ.where(:widget_id => @widgetInfo.id)
    @widgets = Widget.all
    @annotations = @map.annotations.all
    # render json: params
  end

  def update
    m = Map.find(params[:id])
    m.update(map_params)
    redirect_to user_path(current_user.id)
  end

  def destroy
    Map.find(params[:id]).delete
    redirect_to maps_path
  end

  private

  # this is used to prevent mass-assignment of parameters into ActiveRecord models
  def map_params
    params.require(:map).permit(:name, :uniqueUrl, :summary, :article, :bodySystem, :user_id)
  end
end
