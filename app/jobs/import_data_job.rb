class ImportDataJob < ApplicationJob
  queue_as :default

  def perform(club_csv: nil, home_course_csv: nil, tee_csv: nil)
    results = { created: 0, errors: [] }

    if club_csv
      club_data = Rails.root.join(club_csv) # 'club_level_data.csv'
      clean_data = File.read(club_data, encoding: 'bom|utf-8')

      CSV.parse(clean_data, headers: true).each.with_index(1) do |row, index|
        club = Club.find_or_initialize_by(
          club_id: row['facility_id'],
          name: row['facility_name'],
          address: row['address'],
          city: row['city_name'],
          state: row['state_province_name'],
          country: row['country_name'],
          latitude: row['latitude'],
          longitude: row['longitude'],
          postal_code: row['postal_code'],
          number_of_holes: row['number_of_holes'].to_i
        )
        if club.save
          results[:created] += 1
        else
          results[:errors] << "Row #{index}: #{club.errors.full_messages.join(', ')}"
        end
      end
    end

    # import course data
    if home_course_csv
      course_data = Rails.root.join(home_course_csv) # 'course_level_data.csv'
      hc_clean_data = File.read(course_data, encoding: 'bom|utf-8')

      CSV.parse(hc_clean_data, headers: true)&.each&.with_index(1) do |row, index|
        club_id = Club.find_by(club_id: row['facility_id'])&.id || Club.find_by(name: row['facility_id'])&.id
        course = HomeCourse.find_or_initialize_by(
          name: row['course_name'],
          holes_count: row['holes']&.to_i,
          course_id: row['course_id'],
          course_par: row['par'],
          club_id:,
          course_type: row['course_type']
        )

        if course.save
          if course.holes_count > 0
            (1..(course.holes_count || 18)).each do |ind|
              hole = course.holes.find_or_create_by(number: ind)
              hole.update(
                distance: row["hole#{ind}"].to_i,
                female_par: row["hole#{ind}_par_f"].to_i || 4, 
                female_stroke: row["hole#{ind}_handicap_f"].to_i || ind, 
                male_par: row["hole#{ind}_par_m"].to_i || 4, 
                male_stroke: row["hole#{ind}_handicap_m"] || ind
              )
            end
          end
          results[:created] += 1
        else
          results[:errors] << "Row #{index}: #{course.errors.full_messages.join(', ')}"
        end
      end
    end

    # import tee data
    if tee_csv
      tee_data = Rails.root.join(tee_csv) # 'tee_level_data.csv'
      tee_clean_data = File.read(tee_data, encoding: 'bom|utf-8')

      CSV.parse(tee_clean_data, headers: true)&.each&.with_index(1) do |row, index|
        course = HomeCourse.find_by(course_id: row['course_id'])
        club_id = Club.find_by(name: row['facility_id'])&.id || Club.find_by(club_id: row['facility_id'])&.id

        tee = Tee.find_or_initialize_by(
          tee_id: row['tee_id'],
          home_course_id: course.id,
          club_id:,
          name: row['tee_name'],
          slope_rating: row['slope'],
          course_par_for_tee: row['course_par_for_tee'],
          course_rating: row['rating'],
          tee_color: row['tee_color'],
          total_distance: row['total_distance'],
          gender: row['gender']
        )

        if tee.save
          (1..course.holes_count).each do |ind|
            hole = course.holes.find_by(number: ind)
            next unless hole

            # Store tee-specific details in a separate table
            TeeHoleInfo.find_or_create_by(hole:, tee:) do |tee_hole|
              tee_hole.distance = row["hole#{ind}"].to_i
              tee_hole.par = row["hole#{ind}_par"].to_i || 4
              tee_hole.handicap = row["hole#{ind}_handicap"].to_i || ind
            end
          end if course

          par_per_hole = (1..18).map { |hole_number| row["hole#{hole_number}_par_m"].to_i }
          stroke_index_per_hole = (1..18).map { |hole_number| row["hole#{hole_number}_handicap_m"].to_i }

          course.update(par_per_hole:, stroke_index_per_hole:)

          results[:created] += 1
        else
          results[:errors] << "Row #{index}: #{tee.errors.full_messages.join(', ')}"
        end
      end

    end
    results
  end
end
