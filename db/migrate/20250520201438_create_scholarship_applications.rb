class CreateScholarshipApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :scholarship_applications do |t|
      # Basic applicant information
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
      
      # Address information
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
      
      # Education history
      t.string :education_earned
      t.string :school_name
      t.string :school_city
      t.string :school_earned_in
      
      # College information
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
      
      # Educational goals
      t.text :educational_goals
      t.boolean :certify_information
      t.string :signature
      t.date :date
      t.boolean :certify_not_defaulting
      
      # Basic budget information
      t.decimal :tuition, precision: 10, scale: 2
      t.decimal :fees, precision: 10, scale: 2
      t.decimal :room_board, precision: 10, scale: 2
      t.decimal :books, precision: 10, scale: 2
      t.decimal :transportation, precision: 10, scale: 2
      t.decimal :personal_expenses, precision: 10, scale: 2
      t.string :other_expenses
      t.text :resources_college_expenses
      t.decimal :amount_requested, precision: 10, scale: 2
      
      # Application status
      t.string :status
      t.string :reference_number
      
      # Release of information
      t.string :release_signature
      t.date :release_date
      
      # Enrollment verification
      t.string :enrollment_last_name
      t.string :enrollment_first_name
      t.string :enrollment_middle_name
      t.date :enrollment_date_of_birth
      t.string :enrollment_sex
      t.string :enrollment_phone
      t.string :enrollment_place_of_birth
      t.string :enrollment_mailing_city
      t.string :enrollment_mailing_state
      t.string :enrollment_mailing_zip
      
      # Basic financial needs analysis
      t.string :financial_student_name
      t.string :financial_student_id
      t.string :financial_aid_status
      t.string :budget_period
      t.text :student_resources
      
      # Photo release
      t.string :photo_release_signature
      t.date :photo_release_date
      
      # Parental release
      t.string :parental_release_signature
      t.date :parental_release_date
      
      # ARPA section
      t.string :arpa_student_name
      t.boolean :arpa_authorization
      t.string :arpa_signature
      t.date :arpa_date
      
      # Detailed budget fields
      t.decimal :student_contribution, precision: 10, scale: 2
      t.decimal :parent_contribution, precision: 10, scale: 2
      t.decimal :spouse_contribution, precision: 10, scale: 2
      t.string :native_corp_grant1_name
      t.decimal :native_corp_grant1_amount, precision: 10, scale: 2
      t.string :native_corp_grant2_name
      t.decimal :native_corp_grant2_amount, precision: 10, scale: 2
      t.decimal :anb_ans_grant, precision: 10, scale: 2
      t.decimal :pell_grant, precision: 10, scale: 2
      t.decimal :tuition_exemption, precision: 10, scale: 2
      t.decimal :college_work_study, precision: 10, scale: 2
      t.string :college_scholarship_name
      t.decimal :college_scholarship_amount, precision: 10, scale: 2
      t.decimal :alaska_student_loan, precision: 10, scale: 2
      t.decimal :stafford_loan, precision: 10, scale: 2
      t.decimal :alaska_supplemental_loan, precision: 10, scale: 2
      t.decimal :alaska_family_education_loan, precision: 10, scale: 2
      t.decimal :seog_grant, precision: 10, scale: 2
      t.decimal :parent_plus_loan, precision: 10, scale: 2
      t.decimal :government_assistance, precision: 10, scale: 2
      t.decimal :veterans_assistance, precision: 10, scale: 2
      t.string :other_resource1_name
      t.decimal :other_resource1_amount, precision: 10, scale: 2
      t.string :other_resource2_name
      t.decimal :other_resource2_amount, precision: 10, scale: 2
      t.string :other_expense1_name
      t.decimal :other_expense1_amount, precision: 10, scale: 2
      t.string :other_expense2_name
      t.decimal :other_expense2_amount, precision: 10, scale: 2
      t.decimal :total_resources, precision: 10, scale: 2
      t.decimal :total_expenses, precision: 10, scale: 2
      t.decimal :total_expenses_calc, precision: 10, scale: 2
      t.decimal :minus_total_resources, precision: 10, scale: 2
      t.decimal :unmet_need, precision: 10, scale: 2
      t.text :cover_remaining_need
      
      # Expanded Financial Needs Analysis fields
      t.string :financial_college_name
      t.string :financial_student_signature
      t.date :financial_student_date
      t.string :financial_aid_status_other_text
      t.date :budget_period_from
      t.date :budget_period_to
      t.string :budget_period_type
      
      # FNA matrix fields
      t.decimal :fna_family_fall, precision: 10, scale: 2
      t.decimal :fna_family_winter, precision: 10, scale: 2
      t.decimal :fna_family_spring, precision: 10, scale: 2
      t.decimal :fna_family_summer, precision: 10, scale: 2
      t.decimal :fna_family_total, precision: 10, scale: 2
      
      t.decimal :fna_savings_fall, precision: 10, scale: 2
      t.decimal :fna_savings_winter, precision: 10, scale: 2
      t.decimal :fna_savings_spring, precision: 10, scale: 2
      t.decimal :fna_savings_summer, precision: 10, scale: 2
      t.decimal :fna_savings_total, precision: 10, scale: 2
      
      t.decimal :fna_scholarships_fall, precision: 10, scale: 2
      t.decimal :fna_scholarships_winter, precision: 10, scale: 2
      t.decimal :fna_scholarships_spring, precision: 10, scale: 2
      t.decimal :fna_scholarships_summer, precision: 10, scale: 2
      t.decimal :fna_scholarships_total, precision: 10, scale: 2
      
      t.decimal :fna_asl_fall, precision: 10, scale: 2
      t.decimal :fna_asl_winter, precision: 10, scale: 2
      t.decimal :fna_asl_spring, precision: 10, scale: 2
      t.decimal :fna_asl_summer, precision: 10, scale: 2
      t.decimal :fna_asl_total, precision: 10, scale: 2
      
      t.decimal :fna_school_schol_fall, precision: 10, scale: 2
      t.decimal :fna_school_schol_winter, precision: 10, scale: 2
      t.decimal :fna_school_schol_spring, precision: 10, scale: 2
      t.decimal :fna_school_schol_summer, precision: 10, scale: 2
      t.decimal :fna_school_schol_total, precision: 10, scale: 2
      
      t.decimal :fna_work_study_fall, precision: 10, scale: 2
      t.decimal :fna_work_study_winter, precision: 10, scale: 2
      t.decimal :fna_work_study_spring, precision: 10, scale: 2
      t.decimal :fna_work_study_summer, precision: 10, scale: 2
      t.decimal :fna_work_study_total, precision: 10, scale: 2
      
      t.decimal :fna_pell_fall, precision: 10, scale: 2
      t.decimal :fna_pell_winter, precision: 10, scale: 2
      t.decimal :fna_pell_spring, precision: 10, scale: 2
      t.decimal :fna_pell_summer, precision: 10, scale: 2
      t.decimal :fna_pell_total, precision: 10, scale: 2
      
      t.decimal :fna_seog_fall, precision: 10, scale: 2
      t.decimal :fna_seog_winter, precision: 10, scale: 2
      t.decimal :fna_seog_spring, precision: 10, scale: 2
      t.decimal :fna_seog_summer, precision: 10, scale: 2
      t.decimal :fna_seog_total, precision: 10, scale: 2
      
      t.decimal :fna_stafford_fall, precision: 10, scale: 2
      t.decimal :fna_stafford_winter, precision: 10, scale: 2
      t.decimal :fna_stafford_spring, precision: 10, scale: 2
      t.decimal :fna_stafford_summer, precision: 10, scale: 2
      t.decimal :fna_stafford_total, precision: 10, scale: 2
      
      t.decimal :fna_veteran_fall, precision: 10, scale: 2
      t.decimal :fna_veteran_winter, precision: 10, scale: 2
      t.decimal :fna_veteran_spring, precision: 10, scale: 2
      t.decimal :fna_veteran_summer, precision: 10, scale: 2
      t.decimal :fna_veteran_total, precision: 10, scale: 2
      
      t.decimal :fna_tuition_waiver_fall, precision: 10, scale: 2
      t.decimal :fna_tuition_waiver_winter, precision: 10, scale: 2
      t.decimal :fna_tuition_waiver_spring, precision: 10, scale: 2
      t.decimal :fna_tuition_waiver_summer, precision: 10, scale: 2
      t.decimal :fna_tuition_waiver_total, precision: 10, scale: 2
      
      t.decimal :fna_perkins_fall, precision: 10, scale: 2
      t.decimal :fna_perkins_winter, precision: 10, scale: 2
      t.decimal :fna_perkins_spring, precision: 10, scale: 2
      t.decimal :fna_perkins_summer, precision: 10, scale: 2
      t.decimal :fna_perkins_total, precision: 10, scale: 2
      
      t.string :fna_other1_name
      t.decimal :fna_other1_fall, precision: 10, scale: 2
      t.decimal :fna_other1_winter, precision: 10, scale: 2
      t.decimal :fna_other1_spring, precision: 10, scale: 2
      t.decimal :fna_other1_summer, precision: 10, scale: 2
      t.decimal :fna_other1_total, precision: 10, scale: 2
      
      t.string :fna_other2_name
      t.decimal :fna_other2_fall, precision: 10, scale: 2
      t.decimal :fna_other2_winter, precision: 10, scale: 2
      t.decimal :fna_other2_spring, precision: 10, scale: 2
      t.decimal :fna_other2_summer, precision: 10, scale: 2
      t.decimal :fna_other2_total, precision: 10, scale: 2
      
      # FNA Budget fields
      t.decimal :fna_tuition_fees, precision: 10, scale: 2
      t.decimal :fna_room_board, precision: 10, scale: 2
      t.decimal :fna_books, precision: 10, scale: 2
      t.decimal :fna_transportation, precision: 10, scale: 2
      t.decimal :fna_personal, precision: 10, scale: 2
      t.string :fna_other_expense1_name
      t.decimal :fna_other_expense1, precision: 10, scale: 2
      t.string :fna_other_expense2_name
      t.decimal :fna_other_expense2, precision: 10, scale: 2
      
      # FNA Financial aid officer
      t.string :financial_aid_officer_signature
      t.date :financial_aid_officer_date
      t.string :fao_address
      t.string :fao_telephone
      t.string :fao_email

      t.timestamps
    end
  end
end