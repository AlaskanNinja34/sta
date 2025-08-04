class AddMissingFnaFieldsToScholarshipApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :scholarship_applications, :fna_total_cost, :decimal
    add_column :scholarship_applications, :fna_total_resources, :decimal
    add_column :scholarship_applications, :fna_unmet_need, :decimal
  end
end
