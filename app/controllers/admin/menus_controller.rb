class Admin::MenusController < ApplicationController
  before_action :authenticate_admin!, Page.cache_expiration, :set_menu, only: [:show, :edit, :update, :destroy]
  layout "admin"

  # GET /admin/menus
  # GET /admin/menus.json
  def index
    @menus = Menu.all
  end

  # GET /admin/menus/1
  # GET /admin/menus/1.json
  def show
  end

  # GET /admin/menus/new
  def new
    @menu = Menu.new
  end

  # GET /admin/menus/1/edit
  def edit
    @menu = Menu.find(params[:id])
    @pages = Page.position_order(@menu.id)
    @other_pages = Page.where(active: true) - @pages
  end

  # POST /admin/menus
  # POST /admin/menus.json
  def create
    @menu = Menu.new(menu_params)

    respond_to do |format|
      if @menu.save
        format.html { redirect_to [@admin, :menu], notice: 'Menu was successfully created.' }
        format.json { render action: 'show', status: :created, location: @menu }
      else
        format.html { render action: 'new' }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/menus/1
  # PATCH/PUT /admin/menus/1.json
  def update
    respond_to do |format|
      if @menu.update(menu_params)
        format.html { redirect_to [@admin, :menu], notice: 'Menu was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/menus/1
  # DELETE /admin/menus/1.json
  def destroy
    @menu.destroy
    respond_to do |format|
      format.html { redirect_to admin_menus_url }
      format.json { head :no_content }
    end
  end

  def page_sort
    @pm_mapping = PageMenuMapping.where("menu_id = ?", params[:menu])
    if @pm_mapping

      @pm_mapping.each do |pm_mapping| # For removing from the list...
         # Rails.logger.info("#{params[:page]} doesn\'t have the page_menu_mapping: #{pm_mapping.page_id} - #{params[:page].include?(pm_mapping.page_id.to_s)}")
         PageMenuMapping.delete(pm_mapping) unless params[:page].include?(pm_mapping.page_id.to_s)
      end
      params[:page].each do |page| # For adding new elements to the list...
        # Rails.logger.info("#{page} #{page.class} doesn\'t have the page_menu_mapping: #{@ids} - #{@ids.include?(page.to_i)} --- #{@ids.first.class}")
        PageMenuMapping.create(page_id: page, menu_id: params[:menu]) unless @pm_mapping.map(&:page_id).include?(page.to_i)
      end

      @pm_mapping.update_all({page_position: nil}) # Put nil to page position for the uniqueness of menu_id and page_position restriction
      params[:page].each_with_index do |id, index|
        @pm_mapping.update_all({page_position: index + 1}, {page_id: id}) # Finally sorting
      end

    end
    render text: "" #params.inspect #params['page'].index(page.id.to_s) + 1
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_menu
      @menu = Menu.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def menu_params
      params[:admin_menu]
    end
end
