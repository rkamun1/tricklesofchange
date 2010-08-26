require 'spec_helper'

describe UsersController do
	render_views
	
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
		it "should have the right title" do
			get :new
			response.should have_selector("title", :content =>"Sign Up")
		end	
  end
  
  describe "GET 'show'" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end

#    TODO:it "should have a daily bank" do
#      get :show, :id => @user
#      response.should include("Daily Bank")
#    end
    
    it "should show the user's accounts" do
      acct1 = Factory(:account, :user => @user, 
                                :details => "Foo bar", 
                                :cost => "200", 
                                :allotment => "10")
      acct2 = Factory(:account, :user => @user, 
                                :details => "Bar foo", 
                                :cost => "100", 
                                :allotment => "5")
      get :show, :id => @user
      response.should have_selector("div#accountshdr", :content => "accounts")
      response.should have_selector("td.details", :content => acct1.details)
      response.should have_selector("td.cost", :content => acct1.cost.to_s)
      response.should have_selector("td.allotment", :content => acct1.allotment.to_s)
      response.should have_selector("td.accrued", :content => acct1.accrued.to_s)
      #TODO:response.should have_selector("span.remaining", :content => acct1.remaining)
      response.should have_selector("td.details", :content => acct2.details)
      response.should have_selector("td.cost", :content => acct2.cost.to_s)
      response.should have_selector("td.allotment", :content => acct2.allotment.to_s)
      response.should have_selector("td.accrued", :content => acct2.accrued.to_s)
      #TODO:response.should have_selector("span.remaining", :content => acct2.remaining)
    end
  end
  
  describe "GET 'index'" do
    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in non-admin users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
      end

      it "should be unsuccessful" do
        get :index
        response.should_not be_success
      end

      it "should be redirect to user's profile page" do
        get :index
        #TODO: check that it redirects to the user's profile page.
      end
    end

    describe "for signed-in admin users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @user.toggle(:admin)
        second = Factory(:user, :email => "another@example.com")
        third  = Factory(:user, :email => "another@example.net")
        @users = [@user, second, third]
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
    end
  end

  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr = {:name=>"", :email=>"", :password=>"", 
                 :password_confirmation=>"", :daily_bank => ""}
      end
      
      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
      
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign Up")
      end
      
      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end
    
  describe "success" do
      before(:each) do
        @attr = { :name => "New User", 
                  :email => "user@example.com",
                  :password => "foobar", 
                  :password_confirmation => "foobar",
                  :daily_bank => "20"}
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end 
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome/i
      end
      
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end
  
  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end
    
    it "should have a link to change the gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, :content => "change")
    end 
  end
  
  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      before(:each) do
        @invalid_attr = {:email => "", :name =>""}
      end
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @invalid_attr
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @invalid_attr
        response.should have_selector("title", :content => "Edit user")
      end
    end
    
    describe "success" do
      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz", :daily_bank => "20"}
      end
      
      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.name.should  == user.name
        @user.email.should == user.email
        @user.daily_bank.should == user.daily_bank
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "authentication of edit/update pages" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'show'" do
        put :show, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for different signed-in user" do
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'show'" do
        put :show, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end
end

