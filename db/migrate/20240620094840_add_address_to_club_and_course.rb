class AddAddressToClubAndCourse < ActiveRecord::Migration[7.1]
  def change
    #clubs
    add_column :clubs, :address, :string
    add_column :clubs, :postal_code, :string
    add_column :clubs, :city, :string
    add_column :clubs, :state, :string
    add_column :clubs, :country, :string
    add_column :clubs, :latitude, :float
    add_column :clubs, :longitude, :float
    remove_column :clubs, :location_id, :integer

    #courses
    add_column :home_courses, :address, :string
    add_column :home_courses, :postal_code, :string
    add_column :home_courses, :city, :string
    add_column :home_courses, :state, :string
    add_column :home_courses, :country, :string
    add_column :home_courses, :latitude, :float
    add_column :home_courses, :longitude, :float

    drop_table :locations
  end
end
