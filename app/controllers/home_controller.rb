class HomeController < ApplicationController
  
  def index
    @patch = Patch.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patch }
    end
  end

end
