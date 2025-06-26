require "csv"

class Admin::ScholarshipApplicationsController < ApplicationController
  # TODO: Add authentication and authorization before production
  # before_action :authenticate_admin!

  before_action :set_application, only: [ :show, :approve, :reject, :request_more_info, :edit, :update, :destroy ]

  def index
    @applications = ScholarshipApplication.all

    # Filter by status if provided
    if params[:status].present?
      @applications = @applications.where(status: params[:status])
    end

    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @applications = @applications.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email_address ILIKE ? OR reference_number ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    # Order by most recent first
    @applications = @applications.order(created_at: :desc)

    # For status filter dropdown
    @status_options = ScholarshipApplication.distinct.pluck(:status).compact.map { |s| [ s.humanize, s ] }
  end

  def table_view
    @applications = ScholarshipApplication.all

    # Apply filters
    if params[:status].present?
      @applications = @applications.where(status: params[:status])
    end

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @applications = @applications.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email_address ILIKE ? OR reference_number ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    # Date range filter
    if params[:date_from].present?
      @applications = @applications.where("created_at >= ?", params[:date_from])
    end

    if params[:date_to].present?
      @applications = @applications.where("created_at <= ?", params[:date_to])
    end

    # Amount range filter
    if params[:amount_min].present?
      @applications = @applications.where("amount_requested >= ?", params[:amount_min])
    end

    if params[:amount_max].present?
      @applications = @applications.where("amount_requested <= ?", params[:amount_max])
    end

    # Sorting
    sort_column = params[:sort] || "created_at"
    sort_direction = params[:direction] || "desc"
    @applications = @applications.order("#{sort_column} #{sort_direction}")

    # Available columns for the table (this will be customizable)
    @available_columns = {
      "reference_number" => "Reference #",
      "first_name" => "First Name",
      "last_name" => "Last Name",
      "email_address" => "Email",
      "permanent_phone" => "Phone",
      "college_name" => "College",
      "current_degree_program" => "Degree Program",
      "field_of_study" => "Field of Study",
      "class_standing" => "Class Standing",
      "amount_requested" => "Amount Requested",
      "status" => "Status",
      "finance_grant_number" => "Grant Number",
      "board_status" => "Board Status",
      "tribe_enrolled" => "Tribe",
      "marital_status" => "Marital Status",
      "number_of_dependents" => "Dependents",
      "expected_graduation_date" => "Expected Graduation",
      "created_at" => "Application Date",
      "total_expenses" => "Total Expenses",
      "total_resources" => "Total Resources",
      "unmet_need" => "Unmet Need"
    }

    # Default visible columns (can be customized later)
    @default_columns = [
      "reference_number", "first_name", "last_name", "email_address",
      "college_name", "amount_requested", "status", "finance_grant_number",
      "board_status", "created_at"
    ]

    # Get visible columns from params or use defaults
    @visible_columns = params[:columns]&.split(",") || @default_columns

    # For status filter dropdown
    @status_options = ScholarshipApplication.distinct.pluck(:status).compact.map { |s| [ s.humanize, s ] }
    @board_status_options = [ "approved", "denied", "pending" ].map { |s| [ s.humanize, s ] }
  end

  def export_csv
    selected = Array(params[:columns])
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

  def export_applications
    export_csv
  end

  def export_applications
    export_csv
  end

  def show
    # @application is set by before_action
  end

  def edit
    # @application is set by before_action
  end

  def update
    if @application.update(admin_update_params)
      respond_to do |format|
        format.html { redirect_to admin_scholarship_application_path(@application), notice: "Application was successfully updated." }
        format.json { render json: { success: true, message: "Application updated successfully" } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @application.errors.full_messages } }
      end
    end
  end

  def destroy
    @application.destroy
    redirect_to admin_scholarship_applications_path, notice: "Application was successfully deleted."
  end

  def approve
    if @application.update(status: "approved")
      # TODO: Send approval email
      # ApplicationMailer.approval_email(@application).deliver_later
      redirect_to admin_scholarship_application_path(@application), notice: "Application approved successfully!"
    else
      redirect_to admin_scholarship_application_path(@application), alert: "Failed to approve application."
    end
  end

  def reject
    rejection_reason = params[:rejection_reason]

    if @application.update(status: "rejected")
      # TODO: Send rejection email with reason
      # ApplicationMailer.rejection_email(@application, rejection_reason).deliver_later
      redirect_to admin_scholarship_application_path(@application), notice: "Application rejected."
    else
      redirect_to admin_scholarship_application_path(@application), alert: "Failed to reject application."
    end
  end

  def request_more_info
    info_request = params[:info_request]

    if @application.update(status: "more_info_needed")
      # TODO: Send email requesting more information
      # ApplicationMailer.more_info_email(@application, info_request).deliver_later
      redirect_to admin_scholarship_application_path(@application), notice: "Information request sent to applicant."
    else
      redirect_to admin_scholarship_application_path(@application), alert: "Failed to request more information."
    end
  end

  private

  def set_application
    @application = ScholarshipApplication.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_scholarship_applications_path, alert: "Application not found."
  end

  def admin_update_params
    params.require(:scholarship_application).permit(
      :status, :amount_requested, :notes, :finance_grant_number, :board_status,
      # Allow admin to update basic info if needed
      :last_name, :first_name, :email_address, :permanent_phone,
      :college_name, :current_degree_program, :expected_graduation_date,
      :field_of_study, :class_standing
    )
  end

  def export_value(application, column)
    case column
    when "applicant_name"
      "#{application.first_name} #{application.last_name}"
    when "essay_excerpt"
      application.respond_to?(:essay) ? application.essay.to_s[0, 100] : nil
    else
      application.send(column) if application.respond_to?(column)
    end
  end
end
