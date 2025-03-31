class CreateUsersTees < ActiveRecord::Migration[7.1]
  def change
    create_table :users_tees do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tee, null: false, foreign_key: true
      t.integer :match_id, null: false

      t.timestamps
    end
  end
end
