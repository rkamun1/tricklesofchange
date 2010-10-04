class FaqsController < ApplicationController
  def index
    @faqs = Faq.all
  end
  
  def new
    @faq = Faq.new
  end
  
  def create
    @faq = Faq.new(params[:faq])
    if @faq.save
      flash[:notice] = "Successfully created faq."
      redirect_to faqs_url
    else
      render :action => 'new'
    end
  end
  
  def edit
    @faq = Faq.find(params[:id])
  end
  
  def update
    @faq = Faq.find(params[:id])
    if @faq.update_attributes(params[:faq])
      flash[:notice] = "Successfully updated faq."
      redirect_to faqs_url
    else
      render :action => 'edit'
    end
  end
end
