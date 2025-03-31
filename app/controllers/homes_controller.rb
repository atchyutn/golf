class HomesController < ApplicationController
  # before_action :check_tournament, only: :index

  def index
    if current_user&.team
      matches = current_user.team.matches
      @upcoming_matches = matches.where(status: ['match_upcoming', 'upcoming'])
      @completed_matches = matches.where(status: ['match_completed', 'completed'])
      @match_started_matches = matches.where(status: ['match_started', 'started'])
      
      # Redirect logic for started matches
      match_id = @match_started_matches.first&.id
      if @match_started_matches.present?
        if current_user.team.home && current_user.captain?
          redirect_to match_summary_path(id: match_id)
        else
          redirect_to match_in_progress_path(id: match_id)
        end
      end
    else
      @upcoming_matches = []
      @completed_matches = []
      @match_started_matches = []
    end
  end

  private

  def check_tournament
    import_matches
  end
end
