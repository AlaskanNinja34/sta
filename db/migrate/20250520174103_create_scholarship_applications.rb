class CreateScholarshipApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :scholarship_applications do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_initial
      t.string :previous_maiden_name
      t.string :student_id
      t.date :date_of_birth
      t.string :place_of_birth
      t.string :marital_status
      t.integer :number_of_dependents
      t.string :tribe_enrolled
      t.string :previous_scholarship
      t.string :previous_scholarship_year
      t.string :preferred_contact
      t.string :email_address
      t.string :mailing_address_permanent
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :mailing_address_school
      t.string :city_school
      t.string :state_school
      t.string :zip_code_school
      t.string :permanent_phone
      t.string :school_phone
      t.string :education_earned
      t.string :school_name
      t.string :school_city
      t.string :school_earned_in
      t.string :college_name
      t.string :college_financial_aid_office
      t.string :college_phone
      t.string :college_fax
      t.string :college_financial_aid_mailing_address
      t.string :college_city
      t.string :college_state
      t.string :college_zip_code
      t.string :college_term_type
      t.string :deadline_fee_payments
      t.string :credits_taking
      t.string :current_degree_program
      t.date :expected_graduation_date
      t.string :class_standing
      t.string :field_of_study
      t.string :minor
      t.text :educational_goals
      t.boolean :certify_information
      t.string :signature
      t.date :date
      t.boolean :certify_not_defaulting
      t.decimal :tuition
      t.decimal :fees
      t.decimal :room_board
      t.decimal :books
      t.decimal :transportation
      t.decimal :personal_expenses
      t.string :other_expenses
      t.text :resources_college_expenses
      t.decimal :amount_requested
      t.string :status
      t.string :reference_number

      t.timestamps
    end
  end
end
