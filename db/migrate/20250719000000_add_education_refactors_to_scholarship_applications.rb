class AddEducationRefactorsToScholarshipApplications < ActiveRecord::Migration[8.0]
  def up
    # 1. Add a new column with type `date`
    add_column :scholarship_applications, :school_month_year_earned_new, :date

    # 2. Copy data to the new column (convert string to date)
    execute <<-SQL
      UPDATE scholarship_applications
      SET school_month_year_earned_new = 
        CASE
          WHEN school_month_year_earned != '' THEN
            CAST(school_month_year_earned AS DATE)
          ELSE NULL
        END
    SQL

    # 3. Remove the old column
    remove_column :scholarship_applications, :school_month_year_earned

    # 4. Rename the new column to the old column name
    rename_column :scholarship_applications, :school_month_year_earned_new, :school_month_year_earned

    # Add other columns as required
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

  def down
    # Revert the changes made in the `up` method
    add_column :scholarship_applications, :school_month_year_earned_old, :string

    execute <<-SQL
      UPDATE scholarship_applications
      SET school_month_year_earned_old = school_month_year_earned
    SQL

    remove_column :scholarship_applications, :school_month_year_earned
    rename_column :scholarship_applications, :school_month_year_earned_old, :school_month_year_earned

    remove_column :scholarship_applications, :previous_college1_start_date
    remove_column :scholarship_applications, :previous_college1_end_date
    remove_column :scholarship_applications, :previous_college2_start_date
    remove_column :scholarship_applications, :previous_college2_end_date
    remove_column :scholarship_applications, :previous_college3_start_date
    remove_column :scholarship_applications, :previous_college3_end_date

    remove_column :scholarship_applications, :deadline_fee_payments_fall
    remove_column :scholarship_applications, :deadline_fee_payments_winter
    remove_column :scholarship_applications, :deadline_fee_payments_spring
    remove_column :scholarship_applications, :deadline_fee_payments_summer

    remove_column :scholarship_applications, :credits_taking_fall
    remove_column :scholarship_applications, :credits_taking_winter
    remove_column :scholarship_applications, :credits_taking_spring
    remove_column :scholarship_applications, :credits_taking_summer
  end
end
