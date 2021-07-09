class CreateArrows < ActiveRecord::Migration[6.1]
  def change
    create_table :arrows do |t|
      t.text :description
      t.belongs_to :author, null: false, foreign_key: { to_table: :users }
      t.belongs_to :owner, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
