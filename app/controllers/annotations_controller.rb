class AnnotationsController < ApplicationController
  def index

    @annotations = @map.annotation.all
    #where user
  end

  def create
  	#search for map or pass params
    @log = Annotation.create(annotation_params)
    Rails.logger.debug(@log.map_id)
    redirect_to edit_map_path(@log.map_id)
    # redirect_to maps_path(@map)
  end

  def new
    @annotation = Annotation.new
  end

  def edit
    @annotation = Annotation.find(params[:id])
  end

  def show
    @annotation = Annotation.find(params[:id])
    # render json: params
  end

  def update
  	#search for map or pass params
    a = Annotation.find(params[:id])
    a.update(annotation_params)
    redirect_to maps_path(@map)
  end

  def destroy
  	#search for map or pass params
    @annotation = Annotation.find(params[:id]).delete
    @map = @annotation.map_id
    redirect_to edit_map_path(@map)
  end

  private

  # this is used to prevent mass-assignment of parameters into ActiveRecord models
  def annotation_params
    params.require(:annotation).permit(:map_id, :bodyMapUrl, :title, :description, :link, :objectId)
  end
end
