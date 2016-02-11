class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :last_name
      t.string :first_name
      t.integer :book_id
    end
  end
end
