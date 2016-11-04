require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do

  before(:each) do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
  end

  describe "#login" do

    it "should successfully login a student" do
      expect {
        post :login, provider: :github
      }.to change{ Student.count }.by(1)
    end

    it "should successfully login a session" do
      session[:student_id].should be_nil
      post :login, provider: :github
      session[:student_id].should_not be_nil
    end

    it "should redirect the student to the root url" do
      post :login, provider: :github
      response.should redirect_to root_url
    end

  end

  describe "#logout" do
    before do
      post :login, provider: :github
    end

    it "should clear the session" do
      session[:student_id].should_not be_nil
      delete :logout
      session[:student_id].should be_nil
    end

    it "should redirect to the home page" do
      delete :logout
      response.should redirect_to root_url
    end
  end
end