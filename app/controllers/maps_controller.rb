class MapsController < ApplicationController
   def index
    @maps = current_user.maps.all
  end

  def create
  	@user = current_user
    @user.maps.create(map_params)
    redirect_to maps_path
  end

  def new
    @map = Map.new
    @widgets = Widget.all
  end

  def edit
    @map = Map.find(params[:id])
    @annotations = @map.annotations.all
  end

  def show
    @map = Map.find(params[:id])
    # render json: params
  end

  def update
    m = Map.find(params[:id])
    m.update(map_params)
    redirect_to maps_path
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
