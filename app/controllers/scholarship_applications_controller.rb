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
      # Additional fields
      :release_signature, :release_date,
      :enrollment_last_name, :enrollment_first_name, :enrollment_middle_name,
      :enrollment_date_of_birth, :enrollment_sex, :enrollment_phone,
      :enrollment_place_of_birth, :enrollment_mailing_city,
      :enrollment_mailing_state, :enrollment_mailing_zip,
      :financial_student_name, :financial_student_id,
      :financial_aid_status, :budget_period, :student_resources,
      :photo_release_signature, :photo_release_date,
      :parental_release_signature, :parental_release_date,
      :arpa_student_name, :arpa_authorization,
      :arpa_signature, :arpa_date
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