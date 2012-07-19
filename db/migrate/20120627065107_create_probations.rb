class CreateProbations < ActiveRecord::Migration
  def self.up
    create_table :probations do |t|
      t.string :firm_name
      t.string :probation_name
      t.string :probation_type
      t.date :started_at
      t.date :finished_at

      t.timestamps
    end
  end

  def self.down
    drop_table :probations
  end
end
