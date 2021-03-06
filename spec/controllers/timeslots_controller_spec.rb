require 'rails_helper'

RSpec.describe TimeslotsController, type: :controller do

  let(:demo_timeslot) {FactoryGirl.create(:timeslot)}
  let(:demo_student) {FactoryGirl.create(:student)}
  let(:demo_challenge) {FactoryGirl.create(:challenge)}
  let(:demo_challenge_1) {FactoryGirl.create(:challenge)}

  before do
    @request.session[:student_id] = demo_student.id
  end

  describe 'index' do
    context 'when all timeslots are current' do
      before(:each) do
        get :index, params: {challenge_id: demo_timeslot.challenge_id}
      end

      it 'assigns not soon timeslots' do
        expect(assigns(:not_soon_timeslots)).to be_a(Hash)
      end

      it 'assigns soon timeslots' do
        expect(assigns(:soon_timeslots)).to be_a(Hash)
      end

      it 'assigns challenge' do
        expect(assigns(:challenge)).to be_a Challenge
      end
    end

    describe 'get_not_soon_timeslots' do

      let(:same_acceptor_timeslot) {
        timeslot = FactoryGirl.create(:timeslot, :thursday)
        timeslot.acceptor = demo_student
        timeslot.challenge = FactoryGirl.create(:challenge)
        timeslot.save
        timeslot
      }

      before(:each) do
        same_acceptor_timeslot
        challenge = same_acceptor_timeslot.challenge
        list = FactoryGirl.create_list(:timeslot, 50, challenge_id: challenge.id)
        get :index, params: {challenge_id: challenge.id}
      end

      it "returns a hash containing days" do
        expect(assigns(:not_soon_timeslots)).to include(:Monday)
        expect(assigns(:not_soon_timeslots)).to include(:Tuesday)
        expect(assigns(:not_soon_timeslots)).to include(:Wednesday)
        expect(assigns(:not_soon_timeslots)).to include(:Thursday)
      end

      it 'has days containing timeslots' do
        expect(assigns(:not_soon_timeslots)[:Monday]).to all(be_a Timeslot)
      end
    end
  end

  describe 'accept' do

    it 'assigns the current student to the timeslot' do
      demo_timeslot = FactoryGirl.create(:timeslot)
      post :accept, params: {challenge_id: demo_timeslot.challenge_id, id: demo_timeslot.id}
      expect(assigns(:timeslot).acceptor).to eq(demo_student)
    end

    it 'only keeps the timeslot that has an acceptor' do
      demo_timeslot = FactoryGirl.create(:timeslot)
      demo_timeslot_1 = FactoryGirl.create(
        :timeslot,
        challenge_id: demo_timeslot.challenge_id,
        initiator_id: demo_timeslot.initiator_id
      )
      post :accept, params: {challenge_id: demo_timeslot.challenge_id, id: demo_timeslot.id}
      expect(
        Timeslot.where(challenge_id: demo_timeslot.challenge_id, initiator_id:demo_timeslot.initiator_id).count
      ).to eq(1)
    end

    it 'removes all other timeslots that does not have an acceptor' do
      demo_timeslot = FactoryGirl.create(:timeslot)
      demo_timeslot_1 = FactoryGirl.create(
        :timeslot,
        challenge_id: demo_timeslot.challenge_id,
        initiator_id: demo_timeslot.initiator_id
      )
      post :accept, params: {challenge_id: demo_timeslot.challenge_id, id: demo_timeslot.id}
      expect(
        Timeslot.where(
          challenge_id: demo_timeslot.challenge_id, initiator_id:demo_timeslot.initiator_id, acceptor_id: nil
        ).count
      ).to eq(0)
    end

    it 'sends email'do
      expect_any_instance_of(Mail.new.class).to receive(:deliver).twice

      post :accept,
        params: {
          challenge_id: demo_timeslot.challenge_id,
          id: demo_timeslot.id
        }
    end

    it 'removes the timeslot that overlaps the acceptor joined' do
      demo_timeslot = FactoryGirl.create(:timeslot)
      demo_timeslot_1 = FactoryGirl.create(
        :timeslot,
        challenge_id: demo_challenge_1.id,
        initiator_id: demo_timeslot.initiator_id,
        start_at:     demo_timeslot.start_at,
        end_at:       demo_timeslot.end_at
      )
      expect(Timeslot.count).to eq(2)
      post :accept, params: {challenge_id: demo_timeslot.challenge_id, id: demo_timeslot.id}
      expect(Timeslot.count).to eq(1)
    end
  end

  describe 'show' do

    it 'assigns the right timeslot' do
      demo_timeslot = FactoryGirl.create(:timeslot)
      get :show, params: {challenge_id: demo_timeslot.challenge_id, id: demo_timeslot.id}
      expect(assigns(:timeslot)).to eq(demo_timeslot)
    end

    it 'renders the confirmation page' do
      get :show, params: {challenge_id: demo_timeslot.challenge_id, id: demo_timeslot.id}
      expect(response).to render_template(:show)
    end
  end

  describe 'new' do
    it 'renders the confirmation page' do
      get :new, params: {challenge_id: demo_timeslot.challenge_id}
      expect(response).to render_template(:new)
    end
  end

  describe 'destroy' do
    it 'deletes the timeslot from the database' do
      demo_timeslot
      expect{
        delete :destroy, params:
          {
            challenge_id: demo_timeslot.challenge_id,
            id: demo_timeslot.id
          }
        }.to change(Timeslot, :count).by(-1)
    end

    it 'returns to the dashboard page' do
      delete :destroy, params: {challenge_id: demo_timeslot.challenge_id, id: demo_timeslot.id}
      expect(response).to redirect_to dashboard_path
    end
  end

  describe 'cancel' do
    before do
      demo_timeslot.acceptor =  FactoryGirl.create(:student)
      demo_timeslot.save
    end

    it 'deletes the timeslot from the database' do
      expect{
        post :cancel, params:
          {
            challenge_id: demo_timeslot.challenge_id,
            id: demo_timeslot.id
          }
        }.to change(Timeslot, :count).by(-1)
    end

    it 'returns to the dashboard page' do
      post :cancel, params: {
        challenge_id: demo_timeslot.challenge_id,
        id: demo_timeslot.id
      }
      expect(response).to redirect_to dashboard_path
    end

    it 'sends email'do
      expect_any_instance_of(Mail.new.class).to receive(:deliver).twice

      post :cancel, params: {
          challenge_id: demo_timeslot.challenge_id,
          id: demo_timeslot.id
        }
    end

  end

  describe 'create' do
    context "when valid params are passed" do
      before(:each) do
        @request.session[:student_id] = demo_student.id
        post :create, params: { timeslots: {start_date: "2017-10-31", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_challenge.id}
      end
      it "responds with status code 302" do
        expect(response).to have_http_status(302)
      end

      it "redirects to the timeslots page" do
        expect(response).to redirect_to(challenge_timeslots_path)
      end

      it "creates a new timeslot" do
        expect {
          post :create, params: { timeslots: {start_date: "2017-10-30", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_challenge.id}
        }.to change(Timeslot,:count).by(1)
      end
    end

    context "when a past date is submitted" do
      it "renders the form page" do
        post(:create, params: { timeslots: {start_date: "2015-01-01", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_challenge.id})
        expect(response).to render_template("new")
      end

      it "respond with status code 200" do
        post(:create, params: { timeslots: {start_date: "2015-01-01", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_challenge.id})
        expect(response).to have_http_status 200
      end

      it "does not create a new timeslot" do
        expect {
          post(:create, params: { timeslots: {start_date: "2015-01-01", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_challenge.id})
        }.to_not change{ Timeslot.count }
      end
    end

    context "when an end time is before the start time" do
      it "renders the form page" do
        post(:create, params: { timeslots: {start_date: "2117-01-01", start_time: "09:00", end_time: "08:00"}, challenge_id: demo_challenge.id})
        expect(response).to render_template("new")
      end

      it "respond with status code 200" do
        post(:create, params: { timeslots: {start_date: "2117-01-01", start_time: "09:00", end_time: "08:00"}, challenge_id: demo_challenge.id})
        expect(response).to have_http_status 200
      end

      it "does not create a new timeslot" do
        expect {
          post(:create, params: { timeslots: {start_date: "2016-11-06", start_time: "09:00", end_time: "10:00"}, challenge_id: demo_challenge.id})
        }.to_not change{ Timeslot.count }
      end
    end

    context 'create multiple timeslots' do
      it 'creates two 1 hour long timeslots' do
        expect {
            post(:create, params: { timeslots: {start_date: "3000-01-01", start_time: "09:00", end_time: "11:00"}, challenge_id: demo_challenge.id})
          }.to change{ Timeslot.count }.by(2)
      end
    end
  end

end
