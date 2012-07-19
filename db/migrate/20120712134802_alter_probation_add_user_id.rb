class AlterProbationAddUserId < ActiveRecord::Migration
  def up
    add_column("probations", "user_id", :integer)
  end

  def down
    remove_column("probations", "user_id")
  end
end
