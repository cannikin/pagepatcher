require 'mechanize'
require 'hpricot'
require 'open-uri'

class PatchesController < ApplicationController
  
  PATH_LENGTH = 5
  
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
    
    if params[:path]
      @patch = Patch.find_by_path(params[:path])
    else
      @patch = Patch.find(params[:id])
    end
    
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
    
    # remove any beginning or trailing whitespace
    @patch.js.strip!
    @patch.css.strip!
    @patch.url.strip!
    
    # append http on the URL if it isn't already there
    if !@patch.url.match(/^https?:\/\//)
      @patch.url = 'http://' + @patch.url
    end
    # parse the URL so we can access the parts
    @page_url = URI.parse(@patch.url)
    @patch.url = @page_url.to_s
    # append proper <script> wrappers if they're not there
    if !@patch.js.match(/^<script.*?<\/script>$/m)
      @patch.js = '<script type="text/javascript">' + @patch.js + '</script>'
    end
    # append proper <style> wrappers if they're not there
    if !@patch.css.match(/^<style.*?<\/style>$/m)
      @patch.css = '<style type="text/css">' + @patch.css + '</style>'
    end
    
    # set the buffer big so larger pages will still load
    Hpricot.buffer_size = 262144
  
    agent = WWW::Mechanize.new
    source = agent.get(@patch.url)
    
    # go get the source of the page
    # source = Hpricot(open(@patch.url))
    
    # update all relative links in the source and convert to absolute
    source.search('a,img,link,script').each do |element|
      if element.attributes['href']
        link = element.attributes['href']
        attribute = 'href'
      elsif element.attributes['src']
        link = element.attributes['src']
        attribute = 'src'
      else
        link = nil
        attribute = nil
      end

      if link
        begin
          url = URI.parse(link)
          unless url.path.nil?
            if url.scheme.nil?
              url.scheme = @page_url.scheme
              if url.host.nil?
                url.host = @page_url.host
              end
            end
            element.set_attribute(attribute,url.to_s)
          #else
          #  element.set_attribute(attribute,'#')
          end
        rescue URI::InvalidURIError
          logger.error("\n\nINVALID URL: #{link}\n\n")
        end
      end
    end
    
    # stick the modified source into the record
    @patch.html = source.parser.to_s

    # build a unique path to this page
    @patch.path = generate_random_path
    
    respond_to do |format|
      if @patch.save
        flash[:notice] = 'Patch was successfully created.'
        format.html { redirect_to(pretty_path(:path => @patch.path)) }
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
  
  private
  def generate_random_path
    unique = false
    until unique
      path = ''
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      1.upto(PATH_LENGTH) { |i| path << chars[rand(chars.size-1)] }
      unless Patch.find_by_path(path)
        unique = true
      end
    end
    return path
  end
    
end
