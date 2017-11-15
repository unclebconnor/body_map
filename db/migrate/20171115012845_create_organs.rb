class CreateOrgans < ActiveRecord::Migration[5.1]
  def change
    create_table :organs do |t|
      t.string :name
      t.string :objectId
      t.references :widget, foreign_key: true

      t.timestamps
    end
  end
end
