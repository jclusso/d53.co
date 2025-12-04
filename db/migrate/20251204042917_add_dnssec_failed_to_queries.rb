class AddDnssecFailedToQueries < ActiveRecord::Migration[8.1]
  def change
    add_column :queries, :dnssec_failed, :boolean
  end
end
