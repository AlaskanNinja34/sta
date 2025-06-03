# app/controllers/scholarship_applications_controller.rb
class ScholarshipApplicationsController < ApplicationController
  def new
    @application = ScholarshipApplication.new
  end

  def create
    @application = ScholarshipApplication.new(application_params)
    
    # Set initial status
    @application.status = "submitted"
    
    # Generate a unique reference number
    @application.reference_number = generate_reference_number
    
    if @application.save
      # Send confirmation email (we'll implement this later)
      # ApplicationMailer.confirmation_email(@application).deliver_later
      
      redirect_to confirmation_scholarship_application_path(@application)
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
    @application = ScholarshipApplication.find(params[:id])
  end
  
  def confirmation
    @application = ScholarshipApplication.find(params[:id])
  end
  
  def check_status
    # Show the status check form
  end
  
  def lookup
    @application = ScholarshipApplication.find_by(
      reference_number: params[:reference_number],
      email_address: params[:email_address]
    )
    
    if @application
      render :show
    else
      flash.now[:alert] = "No application found matching those details."
      render :check_status
    end
  end
  
  private
  
  # This is the application_params method
  def application_params
    params.require(:scholarship_application).permit(
      # Original application fields
      :last_name, :first_name, :middle_initial, :previous_maiden_name,
      :student_id, :date_of_birth, :place_of_birth,
      :marital_status, :number_of_dependents, :tribe_enrolled,
      :previous_scholarship, :previous_scholarship_year,
      :preferred_contact, :email_address,
      :mailing_address_permanent, :city, :state, :zip_code,
      :mailing_address_school, :city_school, :state_school, :zip_code_school,
      :permanent_phone, :school_phone,
      :education_earned, :school_name, :school_city, :school_earned_in,
      :college_name, :college_financial_aid_office, :college_phone, :college_fax,
      :college_financial_aid_mailing_address, :college_city, :college_state, :college_zip_code,
      :college_term_type, :deadline_fee_payments, :credits_taking,
      :current_degree_program, :expected_graduation_date, :class_standing,
      :field_of_study, :minor, :educational_goals,
      :certify_information, :signature, :date, :certify_not_defaulting,
      :tuition, :fees, :room_board, :books, :transportation, :personal_expenses,
      :other_expenses, :resources_college_expenses, :amount_requested, 
      
      # Education history
      :school_city_state, :school_month_year_earned,
      :previous_college1_name, :previous_college1_dates, :previous_college1_credits, :previous_college1_degree,
      :previous_college2_name, :previous_college2_dates, :previous_college2_credits, :previous_college2_degree,
      :previous_college3_name, :previous_college3_dates, :previous_college3_credits, :previous_college3_degree,
      
      # Release of information fields
      :release_signature, :release_date,
      
      # Enrollment verification fields
      :enrollment_last_name, :enrollment_first_name, :enrollment_middle_name,
      :enrollment_date_of_birth, :enrollment_sex, :enrollment_phone,
      :enrollment_place_of_birth, :enrollment_mailing_city,
      :enrollment_mailing_state, :enrollment_mailing_zip,
      
      # Basic financial needs analysis fields
      :financial_student_name, :financial_student_id, :financial_aid_status,
      :budget_period, :student_resources,
      
      # Photo release fields
      :photo_release_signature, :photo_release_date,
      
      # Parental release fields
      :parental_release_signature, :parental_release_date,
      
      # ARPA fields
      :arpa_student_name, :arpa_authorization, :arpa_signature, :arpa_date,
      
      # Budget fields
      :student_contribution, :parent_contribution, :spouse_contribution,
      :native_corp_grant1_name, :native_corp_grant1_amount,
      :native_corp_grant2_name, :native_corp_grant2_amount,
      :anb_ans_grant, :pell_grant, :tuition_exemption, :college_work_study,
      :college_scholarship_name, :college_scholarship_amount,
      :alaska_student_loan, :stafford_loan, :alaska_supplemental_loan,
      :alaska_family_education_loan, :seog_grant, :parent_plus_loan,
      :government_assistance, :veterans_assistance,
      :other_resource1_name, :other_resource1_amount,
      :other_resource2_name, :other_resource2_amount,
      :other_expense1_name, :other_expense1_amount,
      :other_expense2_name, :other_expense2_amount,
      :total_resources, :total_expenses, :total_expenses_calc,
      :minus_total_resources, :unmet_need, :cover_remaining_need,
      
      # Expanded FNA fields
      :financial_college_name, :financial_student_signature, :financial_student_date,
      :financial_aid_status_other_text, :budget_period_from, :budget_period_to, :budget_period_type,
      
      # FNA matrix fields
      :fna_family_fall, :fna_family_winter, :fna_family_spring, :fna_family_summer, :fna_family_total,
      :fna_savings_fall, :fna_savings_winter, :fna_savings_spring, :fna_savings_summer, :fna_savings_total,
      :fna_scholarships_fall, :fna_scholarships_winter, :fna_scholarships_spring, :fna_scholarships_summer, :fna_scholarships_total,
      :fna_asl_fall, :fna_asl_winter, :fna_asl_spring, :fna_asl_summer, :fna_asl_total,
      :fna_school_schol_fall, :fna_school_schol_winter, :fna_school_schol_spring, :fna_school_schol_summer, :fna_school_schol_total,
      :fna_work_study_fall, :fna_work_study_winter, :fna_work_study_spring, :fna_work_study_summer, :fna_work_study_total,
      :fna_pell_fall, :fna_pell_winter, :fna_pell_spring, :fna_pell_summer, :fna_pell_total,
      :fna_seog_fall, :fna_seog_winter, :fna_seog_spring, :fna_seog_summer, :fna_seog_total,
      :fna_stafford_fall, :fna_stafford_winter, :fna_stafford_spring, :fna_stafford_summer, :fna_stafford_total,
      :fna_veteran_fall, :fna_veteran_winter, :fna_veteran_spring, :fna_veteran_summer, :fna_veteran_total,
      :fna_tuition_waiver_fall, :fna_tuition_waiver_winter, :fna_tuition_waiver_spring, :fna_tuition_waiver_summer, :fna_tuition_waiver_total,
      :fna_perkins_fall, :fna_perkins_winter, :fna_perkins_spring, :fna_perkins_summer, :fna_perkins_total,
      :fna_other1_name, :fna_other1_fall, :fna_other1_winter, :fna_other1_spring, :fna_other1_summer, :fna_other1_total,
      :fna_other2_name, :fna_other2_fall, :fna_other2_winter, :fna_other2_spring, :fna_other2_summer, :fna_other2_total, :fna_total_cost, :fna_total_resources, :fna_unmet_need,
      
      # FNA Budget fields
      :fna_tuition_fees, :fna_room_board, :fna_books, :fna_transportation, :fna_personal,
      :fna_other_expense1_name, :fna_other_expense1, :fna_other_expense2_name, :fna_other_expense2,
      
      # Financial aid officer information
      :financial_aid_officer_signature, :financial_aid_officer_date,
      :fao_address, :fao_telephone, :fao_email
    )
  end
  
  def generate_reference_number
    loop do
      reference = "STA-#{Time.now.year}-#{SecureRandom.alphanumeric(6).upcase}"
      unless ScholarshipApplication.exists?(reference_number: reference)
        return reference
      end
    end
  end
end