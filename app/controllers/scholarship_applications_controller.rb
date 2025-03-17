class ScholarshipApplicationsController < ApplicationController
  def new
    @scholarship_application = ScholarshipApplication.new
  end

  def create
    @scholarship_application = ScholarshipApplication.new(application_params)
    if @scholarship_application.save
      # Redirect to a thank you page or show a success message.
      redirect_to root_path, notice: "Application submitted successfully!"
    else
      # Render the form again with error messages.
      render :new
    end
  end

  private

  def application_params
    # Permit all the fields you want to allow from the form submission.
    params.require(:scholarship_application).permit(
      :last_name, :first_name, :middle_initial, :previous_maiden_name,
      :student_id, :date_of_birth, :place_of_birth, :marital_status,
      :number_of_dependents, :tribe_enrolled, :previous_scholarship,
      :previous_scholarship_year, :preferred_contact, :email_address,
      :mailing_address_permanent, :city, :state, :zip_code,
      :mailing_address_school, :city_school, :state_school, :zip_code_school,
      :permanent_phone, :school_phone, :school_name, :school_city,
      :school_earned_in, :education_earned, :college_name,
      :college_financial_aid_office, :college_phone, :college_fax,
      :college_financial_aid_mailing_address, :college_city, :college_state,
      :college_zip_code, :college_term_type, :deadline_fee_payments,
      :credits_taking, :current_degree_program, :expected_graduation_date,
      :class_standing, :field_of_study, :minor, :educational_goals,
      :certify_information, :signature, :date, :certify_not_defaulting,
      :tuition, :fees, :room_board, :books, :transportation, :personal_expenses,
      :other_expenses, :resources_college_expenses, :amount_requested,
      :release_signature, :release_date, :enrollment_last_name,
      :enrollment_first_name, :enrollment_middle_name, :enrollment_date_of_birth,
      :enrollment_sex, :enrollment_phone, :enrollment_place_of_birth,
      :enrollment_mailing_city, :enrollment_mailing_state, :enrollment_mailing_zip,
      :financial_student_name, :financial_student_id, :financial_aid_status,
      :budget_period, :student_resources, :photo_release_signature, :photo_release_date,
      :parental_release_signature, :parental_release_date, :arpa_student_name,
      :arpa_authorization, :arpa_signature, :arpa_date
    )
  end
end
