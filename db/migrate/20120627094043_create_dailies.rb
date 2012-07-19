class CreateDailies < ActiveRecord::Migration
  def self.up
    create_table :dailies do |t|
      t.string :subject
      t.text :content
      t.boolean :status
      t.references :probation

      t.timestamps
    end
  end

  def self.down
    drop_table :dailies
  end
end
