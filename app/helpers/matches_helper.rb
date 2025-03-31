module MatchesHelper
  def key_matches(key)
    instance_variable_get("@#{key}_matches")
  end

  def team_short(team)
    sorted_players = team.players.sort_by do |player|
      case player.player_type
      when 'captain'
        0
      when 'player'
        1
      when 'reserved_player'
        2
      else
        3
      end
    end
  end

  def course_columns(match)
    @course_handicaps = []
    content = Hash.new { |hash, key| hash[key] = [] }
    match.teams.each do |team|
      captains = team.players.select { |player| player.captain? }
      regular_players = team.players.select { |player| player.player? }
      (captains + regular_players).each do |player|
        next if player.reserved_player?

        users_tee = player.users_tees.where(match_id: match.id).last
        tee = users_tee.tee
        handicap_index = player.handicap
        slope_rating = tee.slope_rating
        par = tee.course_par_for_tee

        @course_handicap = (((handicap_index.to_f * slope_rating.to_f) / $course_rating) + (tee.course_rating.to_f - par.to_f)).round(1)
        @reduced_by_percentage = (@course_handicap * (1 - 0.1)).round(1)
        reduced_handicap = match.course_handicaps.find_or_create_by(user_id: player.id)

        reduced_handicap.update(preview_handicap: @reduced_by_percentage)

        content[:full_name] << content_tag(:th, player.full_name).html_safe

        content[:handicape] << content_tag(:td, player.handicap || '0').html_safe

        content[:tee_color] << content_tag(:td, tee.name).html_safe

        content[:course_difficulty] << content_tag(:td, $course_rating).html_safe

        content[:slope_rating] << content_tag(:td, tee.slope_rating).html_safe

        content[:course_handicaps] << content_tag(:td, @course_handicap.ceil(2)).html_safe

        content[:reduce_ten] << content_tag(:td, @reduced_by_percentage).html_safe

        minimum_handicap = match.course_handicaps.pluck(:preview_handicap).min
        player_match_handicap = match.course_handicaps.find_by(user_id: player.id)
        final_handicap = (player_match_handicap.preview_handicap - minimum_handicap).round
        player_match_handicap.update(final_handicap:)

        content[:final_handicap] << content_tag(:td, final_handicap.ceil(2)).html_safe
      end
    end
    content
  end


  def current_hole_standing(match, team, team_n)
		team1_scores = HoleScore.where(match_id: match.id, user_id: team.players.ids)
		last = team1_scores&.order(hole_number: :asc)&.last
		last&.winner == team_n ? last.standing : ''
  end

  def current_standing(match, start, h_end)
    score = 0
    standing = ''
    color = ''

    # Default to 18 holes if home_course.holes is nil
    max_holes = match.home_course&.holes_count || 18

    (start..h_end).map do |hole|
      if hole <= max_holes
        team1_scores = HoleScore.where(match_id: match.id, hole_number: hole,
                                       user_id: match.teams.first.players.ids)
        score_1 = team1_scores.maximum(:score).to_i
        team2_scores = HoleScore.where(match_id: match.id, hole_number: hole,
                                       user_id: match.teams.second.players.ids)
        score_2 = team2_scores.maximum(:score).to_i

        if team1_scores.present? && team2_scores.present?
          if score_1 == score_2 && score.zero?
            standing = 'AS'
            color = 'black'
          else
            if score_1 > score_2
              team = 'team1'
              if standing.empty? && color.empty?
                score += 1
                color = 'blue' # team 1 color
              elsif color == 'red'
                score -= 1
                color = 'red'
              else
                score += 1
                color = 'blue'
              end
            elsif score_1 < score_2
              team = 'team2'
              if standing.empty? && color.empty?
                score += 1
                color = 'red' # team 2 color
              elsif color == 'blue'
                score -= 1
                color = 'blue'
              else
                score += 1
                color = 'red'
              end
            end

            standing = score.zero? ? 'AS' : "#{score.abs}UP"
          end
        else
          standing = ''
          color = ''
        end

        # **Early Win Check**
        remaining_holes = max_holes - hole
        if score.abs > remaining_holes
          early_winner = score.positive? ? 'Team 1' : 'Team 2'
          @winner = "#{early_winner} Wins Early!"

          match.update(early_win: true, scores_csv: "#{early_winner} (#{score.abs}UP)")
          @remaining_holes = remaining_holes
          @current_hole = hole
          @standing = standing
        end

        # Store the winner and standing in the database
        HoleScore.where(match_id: match.id, hole_number: hole)
                 .update_all(standing:, winner: team)

        content_tag(:td, standing, style: "color: #{color};")
      else
        content_tag(:td, '-')
      end
    end.join.html_safe
  end

	def only_started_matches?
		matches = current_user.team.matches
		(!matches.upcoming.present? && !matches.completed.present? && matches.started.present?)
	end

	def generate_cells(match, type, holes_start, holes_end)
		# Default to 18 holes if home_course.holes is nil
		max_holes = match.home_course&.holes_count || 18
		(holes_start..holes_end).map do |hole|
			if hole <= max_holes
				send("generate_#{type.downcase}_cell", match.home_course, hole)
			else
				content_tag(:td, "-")
			end
		end.join.html_safe
	end

	def generate_shot_cells(player, match, holes_start, holes_end)
	  hole_scores = player.hole_scores.where(match_id: match.id).index_by(&:hole_number)
	  (holes_start..holes_end).map do |hole|
	    if match.home_course&.holes_count.to_i.positive? && hole <= match.home_course.holes_count
	      score_sum = hole_scores[hole]&.shots || '-'
	      content_tag(:td, score_sum)
	    else
	      content_tag(:td, "-") # Display "-" if holes data is missing
	    end
	  end.join.html_safe
	end

  def generate_score_cells(player, match, holes_start, holes_end)
	  hole_scores = player.hole_scores.where(match_id: match.id).index_by(&:hole_number)
	  (holes_start..holes_end).map do |hole|
	    if match.home_course&.holes_count.to_i.positive? && hole <= match.home_course.holes_count
	      score_sum = hole_scores[hole]&.score || '-'
	      content_tag(:td, score_sum)
	    else
	      content_tag(:td, "-") # Display "-" if holes data is missing
	    end
	  end.join.html_safe
	end

	def hole_completion_status(match)
		completion_status = {}
		
		# Define total_holes based on the home course's holes
		total_holes = match.home_course&.holes_count || 18
		
		# Fetch hole scores for all players in the match
		hole_scores = HoleScore.where(user_id: match.teams.flat_map { |team| team.players.only_players.ids })
	
		# Group hole scores by user and match
		scores_by_user = hole_scores.group_by { |hs| [hs.user_id, hs.match_id] }
	
		match.teams.each do |team|
			team.players.only_players.each do |player|
				player_scores = scores_by_user[[player.id, match.id]]&.map(&:hole_number) || []
	
				(1..total_holes).each do |hole_number|
					completion_status[hole_number] = player_scores.include?(hole_number)
				end
			end
		end

		completion_status
	end

	def has_unconfirmed_scores?
		# Get the captain IDs from the teams associated with the match
		captain_ids = @match.teams.map(&:captain).map(&:id)
	
		# Check if any of the users associated with the match have unconfirmed hole scores
		User.where(id: captain_ids).joins(:hole_scores).where(hole_scores: { confirmed: false }).exists?
	end

  def start_valid?
    errors = []
    players = User.joins(team: :matches)
                  .where(matches: { id: @match.id })
                  .where(player_type: %w[captain player])
    handicaps = players.pluck(:handicap)
    tees = players.joins(:users_tees).where(users_tees: { match_id: @match.id }).distinct.count
    errors << 'Only team captain can start the match' unless current_user.captain?
    errors << 'At least two teams are required' unless @match.teams.count >= 2
    # errors << 'All players must have handicaps set' unless handicaps.all?(&:present?)
    # errors << 'Tees must be selected' unless tees.present?
    errors << 'Match time must be set' unless @match.match_time.present?
    errors << 'Match time cannot be in the past' unless @match.match_time.present? && @match.match_time >= Time.now
    if errors.any?
      flash.now[:alert] = errors.join(', ')
      false
    else
      true
    end
    # current_user.home_team_captain? && @match.teams.count >= 2 && handicaps.all?(&:present?) && (tees >= 4) && @match.match_time.present? && @match.match_time >= Time.now
    current_user.captain? && @match.match_time.present? && @match.match_time >= Time.now

  end

  def round_matches(round)
    max_round = current_user.team.cohors.matches.pluck(:round).max
    round_matches = current_user.team.cohors.matches.where(round:)
    if max_round == round
      round_matches.first(1).each_slice(2)
    else
      round_matches.order(id: :asc).each_slice(2)
    end
  end

  def teams_in?(round)
    cohors = current_user.team.cohors
    cohors.matches.includes(:teams).where(round:).map(&:teams).flatten.present?
  end

  def winner
    team = @match.teams.max_by(&:final_standing)
    "#{team.captain.full_name} & #{team.players.find_by(player_type: 'player').full_name}"
  end

  def winner_standing(match, team)
    player1_score, player2_score = match.scores_csv.first.split('-').map(&:to_i)
    winner_id, winning_score = if player1_score > player2_score
                                 [match.player1_id, player1_score]
                               else
                                 [match.player2_id, player2_score]
                               end
    return unless team.participant_id == winner_id

    "#{winning_score} UP"
  end

  private

  def generate_par_cell(course, hole)
    # Default to 4 if par_per_hole is nil or doesn't have enough elements
    # par = course&.par_per_hole&.[](hole - 1) || 4
    male_par = course.holes.find_by(number: hole)&.public_send('male_par')
    male_par = male_par.to_i.zero? ? 4 : male_par
    female_par = course.holes.find_by(number: hole)&.public_send('female_par')
    female_par = female_par.to_i.zero? ? 4 : female_par

		if(male_par == female_par)
			content_tag(:td, male_par)
		else
			content_tag(:td) do
				concat content_tag(:span, male_par, style: "color: DarkBlue;")
				concat " | "
				concat content_tag(:span, female_par, style: "color: deeppink;")
			end			
		end
  end

  def generate_handicap_cell(course, hole)
    # Default to hole number if stroke_index_per_hole is nil or doesn't have enough elements
    # handicap = course&.stroke_index_per_hole&.[](hole - 1) || hole
    male_handicap = course.holes.find_by(number: hole)&.public_send('male_stroke')
    male_handicap = male_handicap.to_i.zero? ? hole : male_handicap
    female_handicap = course.holes.find_by(number: hole)&.public_send('female_stroke')
    female_handicap = female_handicap.to_i.zero? ? hole : female_handicap

		if(male_handicap == female_handicap)
			content_tag(:td, male_handicap)
		else
			content_tag(:td) do
				concat content_tag(:span, male_handicap, style: "color: DarkBlue;")
				concat " | "
				concat content_tag(:span, female_handicap, style: "color: deeppink;")
			end			
		end
  end

  def generate_hole_cell(home_course, hole_number)
    hole = home_course.holes.find_by(number: hole_number)
    if hole
      # Assuming you want to display the par value or some other information
      content_tag(:td, hole.par)
    else
      content_tag(:td, '-') # Placeholder if the hole doesn't exist
    end
  end

	def generate_hole_columns(course, holes_start, holes_end)
		holes = course.holes_count || 18
	  (holes_start..holes_end).map do |hole|
	    content_tag(:th, hole <= holes ? "##{hole}" : "-")
	  end.join.html_safe
	end
end
