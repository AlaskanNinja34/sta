class AddEducationRefactorsToScholarshipApplications < ActiveRecord::Migration[7.1]
  def change
    change_column :scholarship_applications, :school_month_year_earned, :date

    add_column :scholarship_applications, :previous_college1_start_date, :date
    add_column :scholarship_applications, :previous_college1_end_date, :date
    add_column :scholarship_applications, :previous_college2_start_date, :date
    add_column :scholarship_applications, :previous_college2_end_date, :date
    add_column :scholarship_applications, :previous_college3_start_date, :date
    add_column :scholarship_applications, :previous_college3_end_date, :date

    add_column :scholarship_applications, :deadline_fee_payments_fall, :date
    add_column :scholarship_applications, :deadline_fee_payments_winter, :date
    add_column :scholarship_applications, :deadline_fee_payments_spring, :date
    add_column :scholarship_applications, :deadline_fee_payments_summer, :date

    add_column :scholarship_applications, :credits_taking_fall, :integer
    add_column :scholarship_applications, :credits_taking_winter, :integer
    add_column :scholarship_applications, :credits_taking_spring, :integer
    add_column :scholarship_applications, :credits_taking_summer, :integer
  end
end