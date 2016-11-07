require 'rails_helper'

RSpec.describe TimeslotsController, type: :controller do

  let(:demo_timeslot) {FactoryGirl.create(:timeslot)}
  let(:demo_student) {FactoryGirl.create(:student)}
  
  before(:each) do
    @request.session[:student_id] = demo_student.id
  end

  describe 'index' do

    it 'assigns timeslots' do
      get :index, challenge_id: demo_timeslot.challenge_id
      expect(assigns(:timeslots)).to be_a(Hash)
    end

    it 'assigns challenge' do
      get :index, challenge_id: demo_timeslot.challenge_id
      expect(assigns(:challenge)).to be_a Challenge
    end
  end

  describe 'show' do
    before(:each) do
      get :show, challenge_id: demo_timeslot.challenge_id, id: demo_timeslot.id
    end

    it 'assigns the right timeslot' do
      expect(assigns(:timeslot)).to eq(demo_timeslot)
    end

    it 'assigns the current student to the timeslot' do
      expect(assigns(:timeslot).acceptor).to eq(demo_student)
    end
  end

  # pending 'edit' do
  # end

  # pending 'update' do
  # end

  # pending 'destroy' do
  # end

  # pending 'new' do
  # end

  describe 'create' do
    context "when valid params are passed" do
      before(:each) do
        @request.session[:student_id] = demo_student.id
        post :create, timeslots: {start_date: "2016-10-31", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_timeslot.challenge_id
      end
      it "responds with status code 302" do
        expect(response).to have_http_status(302)
      end

      it "redirects to the timeslots page" do
        expect(response).to redirect_to(challenge_timeslots_path)
      end

      it "creates a new timeslot" do
        expect {
          post :create, timeslots: {start_date: "2016-10-31", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_timeslot.challenge_id
        }.to change(Timeslot,:count).by(1)
      end
    end

    context "when invalid params are passed" do
      before(:each) do
        @request.session[:student_id] = demo_student.id
        post :create, timeslots: {start_date: "", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_timeslot.challenge_id
      end
      it "responds with status code 200" do
        post(:create, { timeslots: {start_date: "", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_timeslot.challenge_id})
        expect(response).to have_http_status 200
      end

      it "redirects to the new timeslot page" do
        post(:create, { timeslots: {start_date: "", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_timeslot.challenge_id})
        expect(response).to render_template("new")
      end

      it "does not create a new timeslot" do
        expect {
          post(:create, { timeslots: {start_date: "", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_timeslot.challenge_id})
        }.to_not change(Timeslot,:count)
      end
    end

  end

  describe 'get_timeslot' do
    before(:each) do
      challenge = FactoryGirl.create(:challenge)
      FactoryGirl.create_list(:timeslot, 50, challenge_id: challenge.id)
      get :index, challenge_id: Challenge.first.id
    end

    it "returns a hash containing timeslots" do
      expect(assigns(:timeslots)).to include(:Monday)
      expect(assigns(:timeslots)).to include(:Tuesday)
      expect(assigns(:timeslots)).to include(:Wednesday)
      expect(assigns(:timeslots)).to include(:Thursday)
    end
  end
end