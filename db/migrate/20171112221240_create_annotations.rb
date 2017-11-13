class CreateAnnotations < ActiveRecord::Migration[5.1]
  def change
    create_table :annotations do |t|
      t.references :map, foreign_key: true
      t.string :bodyMapUrl
      t.string :title
      t.text :description
      t.string :link
      t.string :objectId

      t.timestamps
    end
  end
end
