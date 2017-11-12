class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :google
      t.string :788618239670-8sq8cfqrhk1rjh7lejpjupfudrch0irc
      t.string :9GMz217E1uvh8MCnKg5g7XQb
      t.string :email
      t.string :name

      t.timestamps
    end
  end
end
