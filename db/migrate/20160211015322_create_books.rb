class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.integer :author_id
      t.integer :genre_id
      t.integer :user_id
      t.string :on_loaned_to
    end
  end
end
