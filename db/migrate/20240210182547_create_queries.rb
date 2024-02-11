class CreateQueries < ActiveRecord::Migration[7.2]
  def change
    create_table :queries, id: :uuid do |t|
      t.string :domain
      t.string :type
      t.string :server
      t.string :server_ip
      t.json :results, null: false, default: '{}'
      t.integer :duration

      t.timestamps
    end
  end
end
