class CreateMatchTees < ActiveRecord::Migration[7.1]
  def change
    create_table :match_tees do |t|
      t.references :match, null: false, foreign_key: true
      t.references :tee, null: false, foreign_key: true

      t.timestamps
    end
  end
end