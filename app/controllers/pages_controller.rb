class PagesController < ApplicationController
  def about
  	@title = "About"
  end

  def contact
  	@title = "Contact"
  end
  
  def home
  	@title = "Home"
  end
  
  def howitworks
    @title = "How it works"
  end  

  def terms
    @title = "Terms of Use"
  end
end
