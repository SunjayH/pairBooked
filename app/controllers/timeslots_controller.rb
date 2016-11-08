class TimeslotsController < ApplicationController

  def index
    @challenge = Challenge.find_by_id(params[:challenge_id])
    if @challenge
      @timeslots = get_timeslots(@challenge.id)
    else
      redirect_to challenges_path
    end
  end

  def show
    @timeslot = Timeslot.find_by_id(params[:id])
    @timeslot.acceptor = current_student
    @timeslot.save!

    empty_timeslots = Timeslot.where(initiator_id: @timeslot.initiator_id, challenge_id: @timeslot.challenge_id, acceptor_id: nil)
    empty_timeslots.each do |timeslot|
      timeslot.destroy
    end
  end

  def edit
  end

  def update
  end

  def destroy
    Timeslot.destroy(params[:id])
    redirect_to dashboard_path
  end

  def new
  end

  def create
    sanitized_params = timeslots_params
    if sanitized_params[:start_date] != "" && sanitized_params[:start_time] != "" && sanitized_params[:end_time] != ""
      convert_to_datetime(sanitized_params)
    end
    @challenge = Challenge.find_by_id(params[:challenge_id])

    temp_start_at = sanitized_params[:start_at]
    temp_end_at = sanitized_params[:end_at]

    #if the period is greater than 1 hour
      #set the temp_start_at


    #else
      #
    @timeslot = @challenge.timeslots.new(
      start_at:     temp_start_at,
      end_at:       temp_end_at
      )

    @timeslot.initiator = current_student

    respond_to do |format|
      if @timeslot.save
        format.html { redirect_to "/challenges/#{params[:challenge_id]}/timeslots", notice: 'Tweet was successfully created.' }
        format.json { render json: @timeslot, status: :created}
      else
        @errors = @timeslot.errors.full_messages
        format.html { render action: "new" }
        format.json { render json: @timeslot.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def get_timeslots(challenge_id)
    all_timeslots = Timeslot.where(challenge_id: challenge_id, acceptor: nil)
    timeslots = {}

    timeslots[:Monday] = all_timeslots.select do |timeslot|
      timeslot.start_at.strftime("%a") == "Mon"
    end

    timeslots[:Tuesday] = all_timeslots.select do |timeslot|
      timeslot.start_at.strftime("%a") == "Tue"
    end

    timeslots[:Wednesday] = all_timeslots.select do |timeslot|
      timeslot.start_at.strftime("%a") == "Wed"
    end

    timeslots[:Thursday] = all_timeslots.select do |timeslot|
      timeslot.start_at.strftime("%a") == "Thu"
    end

    timeslots[:Friday] = all_timeslots.select do |timeslot|
      timeslot.start_at.strftime("%a") == "Fri"
    end

    timeslots[:Saturday] = all_timeslots.select do |timeslot|
      timeslot.start_at.strftime("%a") == "Sat"
    end

    timeslots[:Sunday] = all_timeslots.select do |timeslot|
      timeslot.start_at.strftime("%a") == "Sun"
    end

    #return a hash with keys of days and values of array of time slots
    timeslots
  end

  def timeslots_params
    params.require(:timeslots).permit( :start_date, :start_time, :end_time)
  end

  def convert_to_datetime(params)
    start_datetime = params[:start_date] + params[:start_time]
    params[:start_at] = DateTime.strptime(start_datetime + Time.zone.to_s[-3..-1],'%F%H:%M %Z')
    end_datetime = params[:start_date] + params[:end_time]
    params[:end_at] = DateTime.strptime(end_datetime + Time.zone.to_s[-3..-1],'%F%H:%M %Z')
  end
end
