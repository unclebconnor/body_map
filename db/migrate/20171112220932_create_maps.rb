class CreateMaps < ActiveRecord::Migration[5.1]
  def change
    create_table :maps do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :uniqueUrl
      t.text :summary
      t.text :article
      t.string :bodySystem

      t.timestamps
    end
  end
end
