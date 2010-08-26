require 'spec_helper'

describe "LayoutLinks" do
  
  it "should have a Welcome page at '/'" do
  	get '/'
  	response.should have_selector('title', :content=> "Welcome")
  end	
  
  it "should have a Contact page at '/contact'" do
  	get '/contact'
  	response.should have_selector('title', :content=> "Contact")
  end	
  
  it "should have a About page at '/about'" do
  	get '/about'
  	response.should have_selector('title', :content=> "About")
  end	
  
  it "should have a signup page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign Up")
  end
  
  describe "when not signed in" do
    it "should land on the sign in/welcome page" do
      visit root_path
      response.should have_selector('title', :content=>"Welcome")
    end        
  end

  describe "when signed in" do
    before(:each) do
      @user = Factory(:user)
      visit signin_path
      fill_in :email,    :with => @user.email
      fill_in :password, :with => @user.password
      click_button
    end

    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path,
                                         :content => "Sign out")
    end

    it "should have a profile link" do
     visit root_path
     response.should have_selector("a", :href => user_path(@user),
                                        :content => "Profile")
    end
    
    it "should redirect to profile page" do
      visit root_path
      response.should have_selector('title', :content => @user.name)
    end
    
    describe "when admin" do
      before(:each) do
        @user.toggle!(:admin)
      end
      
      it "should have a profile link" do
        visit root_path
        response.should have_selector("a", :href => users_path,
                                        :content => "Users")
      end
    end
    
    describe "when on profile page" do
      before(:each) do
        @acct1 = Factory(:account, :user => @user, 
                                  :details => "Foo bar", 
                                  :cost => "200", 
                                  :allotment => "10")
      end
      
      it "should have an add account link" do
        visit users_path
        response.should have_selector("a", :href => new_account_path,
                                           :content => "add account")
      end      
      
      it "should have an edit account link" do
        visit users_path
        response.should have_selector("a", :href => edit_account_path(@acct1),
                                           :content => "edit")
      end      
      
      it "should have an delete account link" do
        visit users_path
        response.should have_selector("a", :href => account_path(@acct1),
                                           :content => "delete")
      end
    end
  end
end
