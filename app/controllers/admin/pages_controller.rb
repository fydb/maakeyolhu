class Admin::PagesController < ApplicationController
  before_action :authenticate_admin!, :set_page, only: [:show, :edit, :update, :destroy]
  layout "admin" # :admin_user_layout
  # GET /admin/pages
  # GET /admin/pages.json
  def index
    @pages = Page.all
  end

  # GET /admin/pages/1
  # GET /admin/pages/1.json
  def show
    @pages = Page.position_order
    @page = Page.find(params[:id])
  end

  # GET /admin/pages/new
  def new
    @page = Page.new
  end

  # GET /admin/pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /admin/pages
  # POST /admin/pages.json
  def create
    @page = Page.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to [:admin, @page], notice: 'Page was successfully created.' }
        format.json { render action: 'show', status: :created, location: @page }
      else
        format.html { render action: 'new' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/pages/1
  # PATCH/PUT /admin/pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to [:admin, @page], notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/pages/1
  # DELETE /admin/pages/1.json
  def destroy
    @page.destroy
    respond_to do |format|
      format.html { redirect_to admin_pages_url }
      format.json { head :no_content }
    end
  end

  def sitemap
    @pages = Page.where("active")
    File.delete("#{Rails.root}/public/sitemap.xml") if File.exists?("#{Rails.root}/public/sitemap.xml")
    sitemap = File.new("#{Rails.root}/public/sitemap.xml", "w")
    sitemap.puts('<?xml version="1.0" encoding="utf-8"?>')
    sitemap.puts('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
    @pages.each do |page|
      sitemap.puts('<url>')
      sitemap.puts("<loc>http://#{request.host_with_port}/#{page.permalink}/</loc>")
      sitemap.puts("<lastmod>#{page.updated_at.strftime("%Y-%m-%d")}</lastmod>")
      sitemap.puts('</url>')
    end
    sitemap.puts('</urlset>')
    sitemap.close
    redirect_to admin_pages_path, notice: 'Sitemap was successfully created.'
  end

  def clear_cache
    Page.cache_expiration
    redirect_to admin_pages_path, notice: 'Cache was successfully sweeped.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params[:admin_page]
    end
end
