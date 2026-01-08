# db/migrate/20260107000001_add_name_fields_to_historical_applications.rb
# Add first_name and last_name to historical_applications for student creation

class AddNameFieldsToHistoricalApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :historical_applications, :first_name, :string
    add_column :historical_applications, :last_name, :string
  end
end
