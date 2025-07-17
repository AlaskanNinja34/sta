# app/controllers/admin/scholarship_applications_controller.rb
require "csv"

class Admin::ScholarshipApplicationsController < ApplicationController
  # TODO: lock this down in production
  # before_action :authenticate_admin!
  before_action :set_application, only: %i[show edit update destroy approve reject request_more_info]

  # simple list view
  def index
    @applications = ScholarshipApplication.all
    @applications = @applications.where(status: params[:status]) if params[:status].present?

    if params[:search].present?
      term = "%#{params[:search]}%"
      @applications = @applications.where(
        "first_name ILIKE :t OR last_name ILIKE :t OR email_address ILIKE :t OR reference_number ILIKE :t",
        t: term
      )
    end

    @applications = @applications.order(created_at: :desc)
    @status_options = ScholarshipApplication.distinct.pluck(:status).compact.map { |s| [s.humanize, s] }
  end

  # Excel-style dashboard
  def table_view
    @applications = ScholarshipApplication.all

    # — Filters —
    @applications = @applications.where(status: params[:status]) if params[:status].present?
    if params[:search].present?
      term = "%#{params[:search]}%"
      @applications = @applications.where(
        "first_name ILIKE :t OR last_name ILIKE :t OR email_address ILIKE :t OR reference_number ILIKE :t",
        t: term
      )
    end
    @applications = @applications.where("created_at >= ?", params[:date_from]) if params[:date_from].present?
    @applications = @applications.where("created_at <= ?", params[:date_to])   if params[:date_to].present?
    @applications = @applications.where("amount_requested >= ?", params[:amount_min]) if params[:amount_min].present?
    @applications = @applications.where("amount_requested <= ?", params[:amount_max]) if params[:amount_max].present?

    # — Sorting —
    sort_col   = params[:sort]      || "created_at"
    sort_dir   = params[:direction] || "desc"
    @applications = @applications.order("#{sort_col} #{sort_dir}")

    # — Column definitions —
    @available_columns = {
      # C
      "first_name"            => "Name",
      "class_standing"        => "Class",

      # (no group)
      "email_address"         => "Email",
      "student_id"            => "Student ID#",

      # STUDENT REQUIREMENTS
      "sta_enroll"            => "STA Enroll",
      "transcript_overall"    => "Transcript",
      "acceptance_letter"     => "Acceptance",
      "budget_period"         => "Budget",
      "fna_total_cost"        => "FNA",
      "fafsa"                 => "FAFSA",

      # GPA
      "gpa"                   => "GPA",

      # SCHOOL & MAJOR
      "field_of_study"        => "MAJOR",
      "college_name"          => "SCHOOL",

      # (no group)
      "vendor_id"             => "Vendor ID#",

      # COMMITTEE ACTION
      "committee_action"      => "Committee Action",
      "amount_awarded"        => "Amt Awarded",
      "term"                  => "Term",

      # ARPA Scholarship
      "arpa_application_page" => "Application Page",
      "arpa_amount_awarded"   => "Amt Awarded",

      # DISTRIBUTION SCHEDULE: HE Code
      "distribution_he_fall_2023"           => "FALL SEMESTER/QUARTER 2023",
      "distribution_he_spring_2022_2023"    => "SPRING SEMESTER/WINTER 2022–23",
      "distribution_he_summer_2024"         => "SUMMER QUARTER 2024",
      "distribution_he_summer_2023"         => "SUMMER QUARTER 2023",

      # DISTRIBUTION SCHEDULE: ARPA Code
      "distribution_arpa_fall_2022"         => "FALL SEMESTER/QUARTER 2022",
      "distribution_arpa_spring_2022_2023"  => "SPRING SEMESTER/WINTER 2022–23",
      "distribution_arpa_spring_2023"       => "SPRING QUARTER 2023",
      "distribution_arpa_summer_2023"       => "SUMMER QUARTER 2023",

      # Reconciliation
      "ties_out_year_payments" => "Ties out Year Payments",

      # TRANSCRIPT SUBMISSION
      "transcript_fall_term"   => "FALL SEMESTER/TERM",
      "transcript_winter_term" => "WINTER TERM",
      "transcript_spring_term" => "SPRING SEMESTER TERM",
      "transcript_summer_term" => "SUMMER TERM",

      # NOTES
      "internal_notes"         => "NOTES"
    }

    # add any existing custom_fields keys
    @applications.each do |app|
      app.custom_fields.keys.each { |k| @available_columns[k] ||= k.humanize }
    end

    # define the exact default order
    default_order = %w[
      first_name class_standing
      email_address student_id
      sta_enroll transcript_overall acceptance_letter budget_period fna_total_cost fafsa
      gpa
      field_of_study college_name
      vendor_id
      committee_action amount_awarded term
      arpa_application_page arpa_amount_awarded
      distribution_he_fall_2023 distribution_he_spring_2022_2023 distribution_he_summer_2024 distribution_he_summer_2023
      distribution_arpa_fall_2022 distribution_arpa_spring_2022_2023 distribution_arpa_spring_2023 distribution_arpa_summer_2023
      ties_out_year_payments
      transcript_fall_term transcript_winter_term transcript_spring_term transcript_summer_term
      internal_notes
    ]

    # either use ?columns=… or fall back
    @visible_columns = (
      (params[:columns]&.split(",")) || default_order
    ) & @available_columns.keys

    # filters for dropdowns
    @status_options       = ScholarshipApplication.distinct.pluck(:status).compact.map { |s| [s.humanize, s] }
    @board_status_options = %w[pending approved denied].map { |s| [s.humanize, s] }
  end

  # Export CSV (used by both export_csv and export_applications)
  def export_csv
    selected     = Array(params[:columns])
    applications = ScholarshipApplication.all.order(created_at: :desc)

    body = CSV.generate(headers: true) do |csv|
      csv << selected
      applications.each do |app|
        csv << selected.map { |col| export_value(app, col) }
      end
    end

    csv_data = "sep=,\n" + body
    send_data csv_data,
              filename: "scholarship_applications-#{Time.zone.now.strftime('%Y%m%d')}.csv",
              type: "text/csv"
  end
  alias export_applications export_csv

  def show; end
  def edit; end

  # Handles both “real” DB columns and JSON custom_fields
  def update
    field = params[:scholarship_application].keys.first
    val   = params[:scholarship_application][field]

    if @application.respond_to?(field)
      @application.update(field => cast_value(field, val))
    else
      @application.custom_fields[field] = val
      @application.save
    end

    respond_to do |format|
      format.json { render json: { success: @application.errors.empty? } }
      format.html { redirect_to admin_scholarship_application_path(@application), notice: "Application updated." }
    end
  end

  def destroy
    @application.destroy
    redirect_to admin_scholarship_applications_path, notice: "Application deleted."
  end

  def approve
    if @application.update(status: "approved")
      # TODO: mailer
      redirect_to admin_scholarship_application_path(@application), notice: "Application approved!"
    else
      redirect_to admin_scholarship_application_path(@application), alert: "Failed to approve."
    end
  end

  def reject
    if @application.update(status: "rejected")
      redirect_to admin_scholarship_application_path(@application), notice: "Application rejected."
    else
      redirect_to admin_scholarship_application_path(@application), alert: "Failed to reject."
    end
  end

  def request_more_info
    if @application.update(status: "more_info_needed")
      redirect_to admin_scholarship_application_path(@application), notice: "More info requested."
    else
      redirect_to admin_scholarship_application_path(@application), alert: "Failed to request more info."
    end
  end

  private

  def set_application
    @application = ScholarshipApplication.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_scholarship_applications_path, alert: "Application not found."
  end

  # Cast boolean/decimal fields appropriately
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
      fna_total_cost budget_period
    ]

    return ActiveRecord::Type::Boolean.new.cast(val) if booleans.include?(field)
    return BigDecimal(val)                if field == "gpa" && val.present?
    return ActiveRecord::Type::Decimal.new.cast(val) if decimals.include?(field)

    val
  end

  # Used for exporting both real + custom fields
  def export_value(application, column)
    if application.respond_to?(column)
      application.public_send(column)
    else
      application.custom_fields[column]
    end
  end
end
