require 'rails_helper'

RSpec.describe Student, type: :model do

  let(:student) {Student.new(
    username: "sleepyhead",
    fullname: "Rip van Winkle",
    email: "sleepyheadzzz@gmail.com",
    slack_name: "rvwinkle"
    )}

  describe "validations" do
    it "saves with valid information" do
      expect(student.save).to be true
    end

    it "saves without a slack_name" do
      student.slack_name = nil
      expect(student.save).to be true
    end

    it "does not allow without username" do
      student.username = nil
      expect(student.save).to be false
    end

    it "does not allow without email" do
      student.email = nil
      expect(student.save).to be false
    end

    it 'sets a timezone if one is not given' do
      student.save
      expect(student.time_zone).to eq("Pacific Time (US & Canada)")
    end

    it 'can have other timezones' do
      student.time_zone = "Eastern Time (US & Canada)"
      student.save
      expect(student.time_zone).to eq("Eastern Time (US & Canada)")
    end

  end

  describe "create_with_omniauth" do
    let(:omniauth_hash) { OmniAuth.config.mock_auth[:github] }
    let(:omniauth_student) { Student.create_with_omniauth(omniauth_hash) }

    it "has a username" do
      expect(omniauth_student.username).to eq("SunjayH")
    end
  end

  describe "associations" do
    let(:acceptor) { FactoryGirl.create(:student) }
    let(:initiator) { FactoryGirl.create(:student) }
    let(:timeslot) {
      timeslot = FactoryGirl.create(:timeslot)
      timeslot.update_attributes(acceptor: acceptor, initiator: initiator)
      timeslot
    }

    it "has many accepted timeslots" do
      expect(acceptor.accepted_timeslots).to include(timeslot)
    end
    it "has many initiated timeslots" do
      expect(initiator.initiated_timeslots).to include(timeslot)
    end
  end
end
