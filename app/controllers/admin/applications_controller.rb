# app/controllers/admin/applications_controller.rb
# Admin controller for managing scholarship applications
require 'csv'

class Admin::ApplicationsController < ApplicationController
  before_action :set_application, only: %i[show edit update destroy approve reject request_more_info view_file]

  # Simple list view
  def index
    @applications = Application.all
    @applications = @applications.where(status: params[:status]) if params[:status].present?

    if params[:search].present?
      term = "%#{params[:search]}%"
      @applications = @applications.where(
        'first_name ILIKE :t OR last_name ILIKE :t OR email_address ILIKE :t OR reference_number ILIKE :t OR application_key ILIKE :t',
        t: term
      )
    end

    @applications = @applications.order(created_at: :desc)
    @status_options = Application::STATUSES.map { |s| [s.humanize, s] }
  end

  # Excel-style dashboard (AppTable)
  def table_view
    @applications = Application.all

    # Filters
    @applications = @applications.where(status: params[:status]) if params[:status].present?
    if params[:search].present?
      term = "%#{params[:search]}%"
      @applications = @applications.where(
        'first_name ILIKE :t OR last_name ILIKE :t OR email_address ILIKE :t OR reference_number ILIKE :t OR application_key ILIKE :t',
        t: term
      )
    end
    @applications = @applications.where('created_at >= ?', params[:date_from]) if params[:date_from].present?
    @applications = @applications.where('created_at <= ?', params[:date_to]) if params[:date_to].present?
    @applications = @applications.where('amount_requested >= ?', params[:amount_min]) if params[:amount_min].present?
    @applications = @applications.where('amount_requested <= ?', params[:amount_max]) if params[:amount_max].present?

    # Sorting
    sort_col = params[:sort] || 'created_at'
    sort_dir = params[:direction] || 'desc'
    @applications = @applications.order("#{sort_col} #{sort_dir}")

    # Column definitions
    @available_columns = {
      # Identity
      'first_name' => 'Name',
      'class_standing' => 'Class',
      'email_address' => 'Email',
      'school_issued_student_id' => 'Student ID#',
      'tribal_id' => 'Tribal ID',
      'application_key' => 'App Key',

      # Student Requirements
      'sta_enroll' => 'STA Enroll',
      'transcript_overall' => 'Transcript',
      'acceptance_letter' => 'Acceptance',
      'budget_period' => 'Budget',
      'fafsa' => 'FAFSA',

      # Academic
      'gpa' => 'GPA',
      'field_of_study' => 'MAJOR',
      'college_name' => 'SCHOOL',

      # Admin
      'vendor_id' => 'Vendor ID#',

      # Committee Action
      'committee_action' => 'Committee Action',
      'amount_awarded' => 'Amt Awarded',
      'term' => 'Term',

      # ARPA
      'arpa_application_page' => 'Application Page',
      'arpa_amount_awarded' => 'ARPA Amt Awarded',

      # Distribution HE
      'distribution_he_fall_2023' => 'HE FALL 2023',
      'distribution_he_spring_2022_2023' => 'HE SPRING 2022-23',
      'distribution_he_summer_2024' => 'HE SUMMER 2024',
      'distribution_he_summer_2023' => 'HE SUMMER 2023',

      # Distribution ARPA
      'distribution_arpa_fall_2022' => 'ARPA FALL 2022',
      'distribution_arpa_spring_2022_2023' => 'ARPA SPRING 2022-23',
      'distribution_arpa_spring_2023' => 'ARPA SPRING 2023',
      'distribution_arpa_summer_2023' => 'ARPA SUMMER 2023',

      # Reconciliation
      'ties_out_year_payments' => 'Ties out Year Payments',

      # Transcript Submission
      'transcript_fall_term' => 'FALL TERM',
      'transcript_winter_term' => 'WINTER TERM',
      'transcript_spring_term' => 'SPRING TERM',
      'transcript_summer_term' => 'SUMMER TERM',

      # Notes
      'internal_notes' => 'NOTES'
    }

    # Default column order
    default_order = %w[
      first_name class_standing
      email_address school_issued_student_id tribal_id application_key
      sta_enroll transcript_overall acceptance_letter budget_period fafsa
      gpa field_of_study college_name
      vendor_id
      committee_action amount_awarded term
      arpa_application_page arpa_amount_awarded
      distribution_he_fall_2023 distribution_he_spring_2022_2023 distribution_he_summer_2024 distribution_he_summer_2023
      distribution_arpa_fall_2022 distribution_arpa_spring_2022_2023 distribution_arpa_spring_2023 distribution_arpa_summer_2023
      ties_out_year_payments
      transcript_fall_term transcript_winter_term transcript_spring_term transcript_summer_term
      internal_notes
    ]

    @visible_columns = ((params[:columns]&.split(',')) || default_order) & @available_columns.keys
    @status_options = Application::STATUSES.map { |s| [s.humanize, s] }
    @board_status_options = Application::BOARD_STATUSES.map { |s| [s.humanize, s] }
  end

  # Export CSV
  def export_csv
    selected = Array(params[:columns])
    applications = Application.all.order(created_at: :desc)

    body = CSV.generate(headers: true) do |csv|
      csv << selected
      applications.each do |app|
        csv << selected.map { |col| export_value(app, col) }
      end
    end

    csv_data = "sep=,\n" + body
    send_data csv_data,
              filename: "applications-#{Time.zone.now.strftime('%Y%m%d')}.csv",
              type: 'text/csv'
  end
  alias export_applications export_csv

  def show; end
  def edit; end

  def update
    app_params = params[:application] || {}

    if app_params.keys == ['uploaded_files']
      # File upload only
      if @application.update(application_params)
        respond_to do |format|
          format.html { redirect_to admin_application_path(@application), notice: 'Files uploaded.' }
          format.json { render json: { success: true } }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { success: false, errors: @application.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    elsif app_params.keys.length == 1
      # Single field update (inline editing)
      field = app_params.keys.first
      val = app_params[field]

      if @application.respond_to?(field)
        @application.update(field => cast_value(field, val))
      else
        @application.custom_fields[field] = val
        @application.save
      end

      respond_to do |format|
        format.json { render json: { success: @application.errors.empty? } }
        format.html { redirect_to admin_application_path(@application), notice: 'Application updated.' }
      end
    else
      # Full form update
      if @application.update(application_params)
        respond_to do |format|
          format.html { redirect_to admin_application_path(@application), notice: 'Application updated.' }
          format.json { render json: { success: true } }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { success: false, errors: @application.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @application.destroy
    redirect_to admin_applications_path, notice: 'Application deleted.'
  end

  def approve
    if @application.update(status: 'approved')
      redirect_to admin_application_path(@application), notice: 'Application approved!'
    else
      redirect_to admin_application_path(@application), alert: 'Failed to approve.'
    end
  end

  def reject
    if @application.update(status: 'rejected')
      redirect_to admin_application_path(@application), notice: 'Application rejected.'
    else
      redirect_to admin_application_path(@application), alert: 'Failed to reject.'
    end
  end

  def request_more_info
    if @application.update(status: 'more_info_needed')
      redirect_to admin_application_path(@application), notice: 'More info requested.'
    else
      redirect_to admin_application_path(@application), alert: 'Failed to request more info.'
    end
  end

  def view_file
    file = ActiveStorage::Blob.find_signed(params[:blob_id])
    if file.content_type == 'application/pdf'
      redirect_to rails_blob_url(file, disposition: 'inline')
    else
      redirect_to rails_blob_url(file, disposition: 'attachment')
    end
  end

  def bulk_update_status
    application_ids = params[:application_ids]
    status = params[:status]

    if application_ids.present? && status.present?
      Application.where(id: application_ids).update_all(status: status)
      render json: { success: true }
    else
      render json: { success: false, error: 'Missing parameters' }, status: :unprocessable_entity
    end
  end

  private

  def set_application
    @application = Application.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_applications_path, alert: 'Application not found.'
  end

  def cast_value(field, val)
    booleans = %w[
      sta_enroll transcript_overall acceptance_letter fafsa
      transcript_fall_term transcript_winter_term
      transcript_spring_term transcript_summer_term
    ]
    decimals = %w[
      amount_awarded arpa_amount_awarded ties_out_year_payments
      distribution_he_fall_2023 distribution_he_spring_2022_2023 distribution_he_summer_2024 distribution_he_summer_2023
      distribution_arpa_fall_2022 distribution_arpa_spring_2022_2023 distribution_arpa_spring_2023 distribution_arpa_summer_2023
    ]

    return ActiveRecord::Type::Boolean.new.cast(val) if booleans.include?(field)
    return BigDecimal(val) if field == 'gpa' && val.present?
    return ActiveRecord::Type::Decimal.new.cast(val) if decimals.include?(field)

    val
  end

  def export_value(application, column)
    if application.respond_to?(column)
      application.public_send(column)
    else
      application.custom_fields[column]
    end
  end

  def application_params
    params.require(:application).permit(
      # Status & Admin
      :status, :board_status, :amount_awarded, :arpa_amount_awarded,
      :gpa, :sta_enroll, :transcript_overall, :acceptance_letter, :fafsa,
      :vendor_id, :committee_action, :term, :internal_notes, :finance_grant_number,

      # Applicant Information
      :first_name, :middle_initial, :last_name, :previous_maiden_name,
      :tribal_id, :school_issued_student_id, :date_of_birth, :place_of_birth,
      :marital_status, :number_of_dependents, :tribe_enrolled,
      :email_address, :permanent_phone, :school_phone, :preferred_contact,

      # Address
      :mailing_address_permanent, :city, :state, :zip_code,
      :mailing_address_school, :city_school, :state_school, :zip_code_school,

      # Education
      :college_name, :current_degree_program, :class_standing,
      :field_of_study, :minor, :expected_graduation_date, :college_term_type,
      :educational_goals, :education_earned, :school_name, :school_city,

      # Financial
      :amount_requested, :tuition, :fees, :room_board, :books,
      :transportation, :personal_expenses, :unmet_need,

      # Transcript Tracking
      :transcript_fall_term, :transcript_winter_term,
      :transcript_spring_term, :transcript_summer_term,

      # Distributions HE
      :distribution_he_fall_2023, :distribution_he_spring_2022_2023,
      :distribution_he_summer_2023, :distribution_he_summer_2024,

      # Distributions ARPA
      :distribution_arpa_fall_2022, :distribution_arpa_spring_2022_2023,
      :distribution_arpa_spring_2023, :distribution_arpa_summer_2023,

      # Reconciliation
      :ties_out_year_payments,

      # Files
      uploaded_files: []
    )
  end
end
