require 'hpricot'
require 'open-uri'

class PatchesController < ApplicationController
  # GET /patches
  # GET /patches.xml
  def index
    @patches = Patch.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patches }
    end
  end

  # GET /patches/1
  # GET /patches/1.xml
  def show
    @patch = Patch.find(params[:id])
    
    # hpricot the source code and append any JS patch to the end
    @output = Hpricot(@patch.html)
    @output.search('body').append(@patch.js) unless @patch.js.blank?
    @output.search('head').append(@patch.css) unless @patch.css.blank?
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @patch }
    end
  end

  # GET /patches/new
  # GET /patches/new.xml
  def new
    @patch = Patch.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patch }
    end
  end

  # GET /patches/1/edit
  def edit
    @patch = Patch.find(params[:id])
  end

  # POST /patches
  # POST /patches.xml
  def create
    @patch = Patch.new(params[:patch])
    @patch.js.strip!
    @patch.css.strip!
    @patch.url.strip!
    
    # append http:// on the URL if it isn't already there
    if !@patch.url.match(/^https?:\/\//)
      @patch.url = 'http://' + @patch.url.to_s
    end
    # append proper <script> wrappers if they're not there
    if !@patch.js.match(/^<script.*?<\/script>$/m)
      @patch.js = '<script type="text/javascript">' + @patch.js + '</script>'
    end
    # append proper <style> wrappers if they're not there
    if !@patch.css.match(/^<style.*?<\/style>$/m)
      @patch.css = '<style type="text/css">' + @patch.css + '</style>'
    end
    
    # go get the source of the page
    @patch.html = open(@patch.url).read
    
    respond_to do |format|
      if @patch.save
        flash[:notice] = 'Patch was successfully created.'
        format.html { redirect_to(@patch) }
        format.xml  { render :xml => @patch, :status => :created, :location => @patch }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @patch.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patches/1
  # PUT /patches/1.xml
  def update
    @patch = Patch.find(params[:id])

    respond_to do |format|
      if @patch.update_attributes(params[:patch])
        flash[:notice] = 'Patch was successfully updated.'
        format.html { redirect_to(@patch) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @patch.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patches/1
  # DELETE /patches/1.xml
  def destroy
    @patch = Patch.find(params[:id])
    @patch.destroy

    respond_to do |format|
      format.html { redirect_to(patches_url) }
      format.xml  { head :ok }
    end
  end
end
