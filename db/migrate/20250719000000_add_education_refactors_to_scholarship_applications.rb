class AddEducationRefactorsToScholarshipApplications < ActiveRecord::Migration[8.0]
  def up
    if ActiveRecord::Base.connection.adapter_name == "SQLite"
      # SQLite-specific code
      add_column :scholarship_applications, :school_month_year_earned_new, :date

      execute <<-SQL
        UPDATE scholarship_applications
        SET school_month_year_earned_new = 
          CASE
            WHEN school_month_year_earned IS NOT NULL THEN
              strftime('%Y-%m-%d', school_month_year_earned)
            ELSE NULL
          END
      SQL

      remove_column :scholarship_applications, :school_month_year_earned
      rename_column :scholarship_applications, :school_month_year_earned_new, :school_month_year_earned

    elsif ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      # PostgreSQL-specific code
      execute <<-SQL
        ALTER TABLE scholarship_applications
        ALTER COLUMN school_month_year_earned TYPE date
        USING school_month_year_earned::date
      SQL
    end

    # Add other columns
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
    if ActiveRecord::Base.connection.adapter_name == "SQLite"
      # SQLite-specific code for rollback
      add_column :scholarship_applications, :school_month_year_earned_old, :string

      execute <<-SQL
        UPDATE scholarship_applications
        SET school_month_year_earned_old = school_month_year_earned
      SQL

      remove_column :scholarship_applications, :school_month_year_earned
      rename_column :scholarship_applications, :school_month_year_earned_old, :school_month_year_earned

    elsif ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
      # PostgreSQL-specific code for rollback
      execute <<-SQL
        ALTER TABLE scholarship_applications
        ALTER COLUMN school_month_year_earned TYPE string
      SQL
    end

    # Remove other columns
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
