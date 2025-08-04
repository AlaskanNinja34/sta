class AddAdminFieldsToScholarshipApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :scholarship_applications, :finance_grant_number, :string
    add_column :scholarship_applications, :board_status, :string
    add_column :scholarship_applications, :custom_fields, :json, default: {}
    add_column :scholarship_applications, :internal_notes, :text
    
    # Add index for board_status for faster filtering
    add_index :scholarship_applications, :board_status
    add_index :scholarship_applications, :finance_grant_number
  end
end