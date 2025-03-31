RailsAdmin.config do |config|
  config.asset_source = :importmap

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)
  config.authenticate_with do
    redirect_to main_app.new_admin_session_path unless current_admin
  end
  config.current_user_method(&:current_admin)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete

    member :start do
      visible do
        bindings[:abstract_model]&.model_name == 'Cohors'
      end

      register_instance_option :controller do
        proc do
          if request.get? # Display confirmation form
            @abstract_model = RailsAdmin.config(@object.class).abstract_model
            @model_config = @abstract_model.config
            @object = @abstract_model.get(params[:id])
            render :start
          elsif request.post? # Process start action
            challonge_api = TournamentService.new(@object)
            response = challonge_api.start_tournament

            if response != 200
              flash[:error] = response[:errors]
            else
              @users = User.includes(team: :cohors).where(cohors: { id: @object.id })
              @users.each do |user|
                UserNotifierMailer.with(user:, tournament: @object).tournament_started.deliver_now
              rescue Net::OpenTimeout => e
                logger.error "Failed to send email to #{player.email}: #{e.message}"
              end
              flash[:success] = "#{@object.name} started successfully"
            end

            redirect_to back_or_index
          end
        end
      end

      # Provide a confirmation dialog
      register_instance_option :link_icon do
        'fa-solid fa-play-circle'
      end

      register_instance_option :http_methods do
        %i[get post]
      end
    end

    # Define a reusable import collection function
    def create_import_collection(resource_name, csv_param_key)
      collection :"import_#{resource_name.underscore.pluralize}" do
        visible do
          bindings[:abstract_model]&.model_name == resource_name
        end

        register_instance_option :link_icon do
          'fa-solid fa-file-import'
        end

        register_instance_option :controller do
          proc do
            if request.get?
              @url = rails_admin.public_send("import_#{resource_name.underscore.pluralize}_path",
                                             model_name: resource_name.underscore)
              render action: :import_csv
            elsif request.post? && params[:file].present?
              result = ImportDataJob.new(csv_param_key => params[:file]).perform_now
              if result.present?
                flash[:success] = "#{result[:created]} #{resource_name.pluralize} imported successfully."

                errors = result[:errors]
                flash[:error] = "Some records failed to import: #{errors} " if errors.any?
              else
                flash[:error] = 'Something went wrong during import.'
              end
              redirect_to back_or_index
            else
              flash[:error] = 'Please upload a CSV file.'
              redirect_to back_or_index
            end
          end
        end

        register_instance_option :http_methods do
          %i[get post]
        end
      end
    end

    # Use the function for each resource
    create_import_collection('Club', :club_csv)
    create_import_collection('HomeCourse', :home_course_csv)
    create_import_collection('Tee', :tee_csv)

    # Define a reusable collection function for sample CSV download
    def create_sample_csv_collection(resource_name, sample_file_path)
      collection :"sample_csv_for_#{resource_name.underscore.pluralize}" do
        visible do
          bindings[:abstract_model]&.model_name == resource_name
        end

        register_instance_option :link_icon do
          'fa-solid fa-file-arrow-down'
        end

        register_instance_option :controller do
          proc do
            file_path = Rails.root.join(sample_file_path)

            if File.exist?(file_path)
              send_file file_path,
                        filename: "#{resource_name.underscore}_sample.csv",
                        type: 'text/csv',
                        disposition: 'attachment'
            else
              flash[:error] = 'Sample file not found.'
              redirect_to back_or_index
            end
          end
        end

        register_instance_option :http_methods do
          [:get]
        end
      end
    end

    # Use the function for each resource
    create_sample_csv_collection('Club', 'club_level_data.csv')
    create_sample_csv_collection('HomeCourse', 'course_level_data.csv')
    create_sample_csv_collection('Tee', 'tee_level_data.csv')

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.included_models = %w[Cohors Region Team User HomeCourse Club Admin Tee Match Hole]

  config.model User do
    label 'Player'
    label_plural 'Players'
    list do
      field :id
      field :email
      field :first_name
      field :last_name
      field :phone_number
      field :handicap
      field :label
      field :team
      field :player_type
      field :country
      field :postcode
      field :provider
      field :uid
      field :home_course
      field :created_at
      field :updated_at
    end
    edit do
      field :email
      field :first_name
      field :last_name
      field :phone_number
      field :handicap
      field :label
      field :team
      field :home_course
      field :player_type
      field :country
      field :postcode
    end
    show do
      field :id
      field :email
      field :first_name
      field :last_name
      field :phone_number
      field :handicap
      field :label
      field :team
      field :home_course
      field :player_type
      field :country
      field :postcode
      field :provider
      field :uid
      field :created_at
      field :updated_at
    end
  end

  config.model Tee do
    list do
      field :id
      field :tee_id
      field :home_course
      field :club
      field :name
      field :gender
      field :slope_rating
      field :course_par_for_tee
      field :course_rating
      field :created_at
      field :updated_at
    end
    edit do
      field :id
      field :tee_id
      field :home_course
      field :club
      field :total_distance
      field :gender
      field :tee_color
      field :name
      field :gender
      field :slope_rating
      field :course_par_for_tee
      field :course_rating
      field :holes
      field :tee_hole_infos
    end
    show do
      field :id
      field :tee_id
      field :home_course
      field :club
      field :holes
      field :total_distance
      field :gender
      field :tee_color
      field :name
      field :gender
      field :slope_rating
      field :course_par_for_tee
      field :course_rating
      field :tee_hole_infos
      field :created_at
      field :updated_at
    end
  end

  config.model Team do
    list do
      field :id
      field :name
      field :home
      field :participant_id
      field :payment_status
      field :paid_by
      field :home_course
      field :cohors do
        label :Cohorts
      end
      field :tournament_id
      field :group_player_ids
      field :captain
      field :players
      field :reserved_players
      field :matches
      field :eliminated
      field :disqualified
      field :created_at
      field :updated_at
    end
    edit do
      field :id
      field :name
      field :home
      field :participant_id
      field :payment_status
      field :paid_by
      field :home_course
      field :cohors do
        label :Cohorts
      end
      field :tournament_id
      field :disqualified
      field :group_player_ids
    end
    show do
      exclude_fields :final_standing
      configure :cohors do
        label :Cohorts
      end
    end
  end

  config.model Match do
    list do
      field :id
      field :match_time
      field :status
      field :tournament_id
      field :cohors do
        label :Cohorts
      end
      field :round
      field :match_id
      field :home_team_captain do
        formatted_value do
          if value.present? && value.present?
            bindings[:view].link_to(value.full_name,
                                    bindings[:view].rails_admin.show_path(model_name: 'User', id: value.id))
          end
        end
      end
      field :player1_id do
        label :'Team 1'
      end
      field :player2_id do
        label :'Team 2'
      end
      field :winner_id
      field :loser_id
      field :early_win
      field :scores_csv
      field :home_course
      field :teams
      field :created_at
      field :updated_at
    end
    edit do
      field :match_time
      field :winner_id
      field :loser_id
      field :home_course
    end
    show do
      configure :cohors do
        label :Cohorts
      end
    end
  end

  config.model Cohors do
    label 'Cohort'
    label_plural 'Cohorts'
    create do
      field :name
      field :region
      field :tournament_type
      field :starts_at
      field :description
      # field :is_final_tournament do
      #   label 'PlayOff'
      # end
      field :teams do
        associated_collection_scope do
          proc do |scope|
            scope.merge(Team.with_completed_payment_and_two_players.not_in_any_cohors)
          end
        end
      end
    end
    edit do
      field :name
      field :region
      field :starts_at
      field :description
      # field :is_final_tournament do
      #   label 'PlayOff'
      # end
      field :teams do
        associated_collection_scope do
          cohors = bindings[:object]
          proc do |scope|
            scope.merge(Team.with_completed_payment_and_two_players.not_in_any_cohors_except(cohors))
          end
        end
      end
    end
    list do
      field :id
      field :name
      # field :is_final_tournament do
      #   label 'PlayOff'
      # end
      field :description
      field :state
      field :game_name
      field :region
      field :starts_at
      field :tournament_type
      field :tournament_id
      field :url
      field :full_challonge_url
      field :live_image_url
      field :teams
      field :created_at
      field :updated_at
    end
  end

  config.model Region do
    list do
      field :id
      field :name
      field :created_at
      field :updated_at
    end
    edit do
      field :name
    end
  end
end
