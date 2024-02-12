class AddSessionIdToQuery < ActiveRecord::Migration[7.2]
  def change
    add_column :queries, :session_id, :string
  end
end
