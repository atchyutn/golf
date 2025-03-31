class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.datetime :match_time
      t.integer :status
      t.string :address

      t.timestamps
    end
  end
end
