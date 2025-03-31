class MatchesController < ApplicationController
  before_action :find_match, except: %i[index upcoming_matches update_team]
  after_action :send_confirmation_link, only: :submit_scores
  before_action :set_cohors, only: [:submit_scores]

  def index
    # Ensure the user has a team before trying to fetch matches
    if current_user&.team
      matches = current_user.home_course.matches
      @upcoming_matches = matches.where(status: ['match_upcoming', 'upcoming'])
      @completed_matches = matches.where(status: ['match_completed', 'completed'])
      @match_started_matches = matches.where(status: ['match_started', 'started'])
    else
      # Handle case where user has no team
      @upcoming_matches = []
      @completed_matches = []
      @match_started_matches = []
    end

    # Render the matches view
    render 'matches/index'
  end

  def edit
    if @match.home_course.nil?
      flash.now[:alert] = 'No home course selected'
    else
      available_tees = @match.home_course.tees.where("COALESCE(slope_rating, '') != ?", 'N/D')
      flash.now[:alert] = 'No tees available for this course' if available_tees.empty?
    end
  end

  def update
    if @match.update(match_params)
      updated = false # Flag to check if any updates were made
  
      if params[:player_tees].present?
        params[:player_tees].each do |player_id, tee_color|
          player = User.find_by(id: player_id)
          next unless player
  
          tee = @match.home_course&.tees&.find_by(name: tee_color)
          if tee
            user_tee = player.users_tees.find_or_create_by(match_id: @match.id)
            user_tee.update(tee_id: tee.id)
            updated = true # Set flag to true if any tee is updated
          end
        end
      end
  
      if params[:player_handicaps].present?
        params[:player_handicaps].each do |player_id, handicap_value|
          player = User.find_by(id: player_id)
          next unless player
  
          # Update the player's handicap
          player.update(handicap: handicap_value)
          updated = true # Set flag to true if any handicap is updated
        end
      end
  
      # Set a single success message if any updates were made
      flash[:notice] = 'Tees & handicaps updated successfully' if updated
  
      json_response = {
        message: 'updated successfully',
        address: @match.home_course&.name,
        handicap: current_user.handicap,
        match_time: @match.match_time,
        status: @match.status,
        partial_html: render_to_string(partial: 'matches/edit')
      }
      render json: json_response, status: 200
    else
      render json: { errors: @match.errors.full_messages }, status: 500
    end
  end

  def match_summary
    begin
      # Update match status if it's upcoming
      if @match.status == 'upcoming'
        ActiveRecord::Base.transaction do
          @match.update!(match_time: Time.current)
          @match.update!(status: 'started')
        end
      end

      # Validate match teams
      if @match.teams.count < 2
        flash[:warning] = 'This match requires at least two teams to proceed.'
      end

      # Check for draw
      @draw_message = check_draw
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = 'Could not update match status. Please try again.'
    rescue StandardError => e
      # Catch and log any unexpected errors
      Rails.logger.error e.backtrace.join("\n")
      flash[:error] = 'An unexpected error occurred. Our team has been notified.'
    end
  end

  def edit_scores
    @initial_slide = find_first_incomplete_hole(@match)
  end

  def match_summary
    @match = Match.find(params[:id])
  end

  def submit_scores
    @match = Match.find(params[:id])
    @cohors = @match.cohors
    tournament_service = TournamentService.new(@cohors)
    tournament_service.update_match_standings
    @hole_number = params[:match][:current_hole_number].to_i

    if @hole_number <= 0
      flash[:error] = 'Invalid hole number.'
      redirect_to match_summary_path(id: @match.id) and return
    end

    @match.update(status: 'started') if @match.status == 'upcoming'

    params[:match].each do |key, value|
      next unless key.start_with?('team_') && key.end_with?('_id')

      @player_id = value.to_i
      player_shots_key = key.sub('_id', '')
      @player_shots = params[:match][player_shots_key].to_i

      hole_score = HoleScore.find_or_create_by(
        hole_number: @hole_number,
        user_id: @player_id,
        match_id: @match.id
      )

      hole_score.update(shots: @player_shots, score: score_calculation, confirmed: (current_user.id == @player_id))
    end
    update_standings
    # early_win
    redirect_to match_summary_path(id: @match.id)
  end

  def final_scores
    @match = Match.find(params[:id])
    @match.update(status: 'completed')
  
    # Process elimination to get winner and loser
    winner_id, loser_id = process_elimination(@match)
    @winner = @match.teams.find(winner_id)
    # Prepare JSON response
    response_data = {
      winner: {
        name: @winner.name,
        players: @winner.players.map { |player| 
          {
            full_name: player.full_name,
            image_url: player.image.attached? ? url_for(player.image) : nil
          }
        }
      },
      team1_score: @match.teams.first.final_standing,
      team2_score: @match.teams.second.final_standing,
      standing: @match.hole_scores.all.order(hole_number: :asc).last.standing,
      remaining_holes: @match.home_course.holes_count - @match.hole_scores.all.order(hole_number: :asc).last.hole_number,
    }
    
    
    # Respond to different formats
    respond_to do |format|
      format.json { render json: response_data }
      format.js   # Will render final_scores.js.erb
      format.html { redirect_to match_summary_path(id: @match.id) }
    end
  end
  

  def upcoming_matches
    @cohors = current_user.team.cohors if current_user&.team
    # Add a check for cohors being nil
    if @cohors.nil?
      @matches = []
      @winner_rounds = []
      @loser_rounds = []
      @cohors_pending = false
      return
    end
    # Check if cohors is pending
    @cohors_pending = @cohors.respond_to?(:pending?) ? @cohors.pending? : false

    @matches = @cohors.matches.order(round: :asc) #.where(status: ['match_upcoming', 'upcoming']).order(round: :asc)
    # Separate winner and loser rounds
    @winner_rounds = @matches.where('round > 0').map(&:round).uniq
    @loser_rounds = @matches.where('round < 0').map(&:round).uniq
  end

  def update_team
    @match = Match.find(params[:match_id])
    teams_params = [
      { team_id: params[:team_1_id], player_1_id: params[:team_1_player_1], player_2_id: params[:team_1_player_2] },
      { team_id: params[:team_2_id], player_1_id: params[:team_2_player_1], player_2_id: params[:team_2_player_2] }
    ]

    teams_params.each do |team_params|
      team = Team.find_by(id: team_params[:team_id])
      captain_id = team_params[:player_1_id]
      player_id = team_params[:player_2_id]
      captain = begin
        User.find_by(id: captain_id)
      rescue StandardError
        nil
      end
      player = begin
        User.find_by(id: player_id)
      rescue StandardError
        nil
      end

      captain.update(player_type: 'captain') if captain
      player.update(player_type: 'player') if player
      next if captain.nil? && player.nil?

      rest_of_players = team.players.where.not(id: [captain&.id, player&.id])
      rest_of_players.each do |player|
        player.update(player_type: 'reserved_player')
      end
    end
    redirect_to course_handicap_calculation_path(id: @match)
  end

  helper_method :round_matches

  def round_matches(round)
    return [] unless @cohors

    matches = @matches.where(round:)
    matches
  end

  def score_calculation
    # stroke_index = @match.home_course.stroke_index_per_hole[@hole_number-1]
    tee = UsersTee.find_by(match: @match, user_id: @player_id)&.tee
    hole = @match.home_course.holes.find_by(number: @hole_number)

    if hole && (tee&.gender == 'woman' || tee&.gender == 'female')
      par = hole.female_par
      player_strok = hole.female_stroke
    elsif hole && (tee&.gender == 'man' || tee&.gender == 'male')
      par = hole&.male_par
      player_strok = hole.female_stroke
    else
      par = 4
      player_strok = 0
    end

    player_handicap = @match.course_handicaps.find_by(user_id: @player_id)&.final_handicap.to_i
    handicap_stroke_indexes = YAML.load_file(Rails.root.join('config', 'handicap_stroke_index.yml'))

    extra_stroke = handicap_stroke_indexes.dig(player_handicap.to_s, player_strok.to_s).to_i

    (2 - [2, (@player_shots - par)].min) + extra_stroke
  end

  def find_match
    @match = Match.find(params[:id]) # Ensure this is correct
  end

  def set_cohors
    @cohors = @match.cohors
  end

  private

  def find_match
    @match = Match.find(params[:id])
  end

  def match_params
    params.require(:match).permit(:match_time, :home_course_id, :status)
  end

  def find_first_incomplete_hole(match)
    (1..match.home_course.holes_count).each do |hole_number|
      return hole_number unless HoleScore.exists?(match_id: match.id, hole_number:)
    end

    0
  end

  def update_standings
    TournamentService.new(@match.cohors).update_match_standings
  end

  def send_confirmation_link
    user = @match.teams.includes(:matches).where(home: false).last&.captain
    if user && (@match.home_course.holes_count == @hole_number || @match.early_win) && !all_final_standings_zero?
      UserNotifierMailer.with(user:, match: @match).confirm_scores.deliver_now
    end
  end

  def all_final_standings_zero?
    @match.teams.pluck(:final_standing).all?(&:zero?)
  end

  def check_draw
    # Assuming scores_csv contains scores for player1 and player2 in order
    scores = @match.scores_csv

    # Check if both scores are present and equal
    return true if scores.length >= 2 && scores[0] == scores[1]

    # The match is a draw

    false # The match is not a draw
  end

  def get_par_for_hole(hole_number)
    hole = Hole.find_by(number: hole_number)
    if hole
      hole.par
    else
      # Handle the case where the hole does not exist
      puts "Warning: Hole with number #{hole_number} not found."
      nil # or return a default value if appropriate
    end
  end
end
