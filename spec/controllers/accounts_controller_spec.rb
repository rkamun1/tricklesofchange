require 'spec_helper'

describe AccountsController do
	render_views
	
	describe "not signed in user" do
    describe "GET 'new'" do
  
      it "should deny access" do
        get 'new'
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
    
    describe "POST 'create'" do
  
      it "should deny access" do
        post 'create'
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
    
    describe "GET 'edit'" do
  
      it "should deny access" do
        get :edit, :id => '?'
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
    
    describe "DELETE 'destroy'" do
      it "should deny access" do
        delete 'destroy', :id => '?'
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
  end
      
  describe "signed in user" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @account = Factory(:account, :user => @user)
    end
    
    describe "GET 'new'" do     
      it "should be successful" do
        get :new
        response.should be_success
      end
      
      it "should have the right title" do
        get :new
        response.should have_selector("title", :content => "new account")
      end
    end
    
    describe "POST 'create'" do
      it "should be successful" do
        post :create
        response.should be_success
      end
    end
    
    describe "GET 'edit'" do
      it "should be successful" do
        get :edit, :id => @account
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @account
        response.should have_selector("title", :content => @account.details)
      end
    end
    
    describe "GET 'delete'" do
      it "should destroy the account" do
        lambda do
          delete :destroy, :id => @account
        end.should change(Account, :count).by(-1)
      end
    end
    
    describe "for different signed-in user" do
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      describe "GET 'edit'" do
        it "should require matching user for 'edit'" do
           get :edit, :id => @account
           response.should redirect_to(root_path)
        end
      end

      describe "PUT 'update'" do
        it "should require matching user for 'update'" do
           put :update, :id => @account
           response.should redirect_to(root_path)
        end
      end
        
      describe "DELETE 'destroy'" do
        it "should require matching user for 'delete'" do
          delete :destroy, :id => @account.id
          response.should redirect_to(root_path)
        end
      end
    end
  end
end
