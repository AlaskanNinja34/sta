class AddEducationHistoryFieldsToScholarshipApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :scholarship_applications, :school_city_state, :string
    add_column :scholarship_applications, :school_month_year_earned, :string
    add_column :scholarship_applications, :previous_college1_name, :string
    add_column :scholarship_applications, :previous_college1_dates, :string
    add_column :scholarship_applications, :previous_college1_credits, :integer
    add_column :scholarship_applications, :previous_college1_degree, :string
    add_column :scholarship_applications, :previous_college2_name, :string
    add_column :scholarship_applications, :previous_college2_dates, :string
    add_column :scholarship_applications, :previous_college2_credits, :integer
    add_column :scholarship_applications, :previous_college2_degree, :string
    add_column :scholarship_applications, :previous_college3_name, :string
    add_column :scholarship_applications, :previous_college3_dates, :string
    add_column :scholarship_applications, :previous_college3_credits, :integer
    add_column :scholarship_applications, :previous_college3_degree, :string
  end
end
