# app/controllers/admin/verifications_controller.rb
# Admin controller for verification workflow management

class Admin::VerificationsController < ApplicationController
  helper Admin::ApplicationsHelper
  before_action :set_verification_template, only: %i[show update]

  # Excel-like workflow view - main staff processing interface
  def workflow
    @applications = Application.includes(:student, :verification_template)
                               .order(created_at: :desc)

    # Filter by search term
    if params[:search].present?
      term = "%#{params[:search]}%"
      @applications = @applications.where(
        'first_name ILIKE :t OR last_name ILIKE :t OR email_address ILIKE :t OR application_key ILIKE :t',
        t: term
      )
    end

    # Filter by status if specified
    if params[:status].present? && params[:status] != ''
      @applications = @applications.where(status: params[:status])
    end

    # Filter by date range
    if params[:date_from].present?
      @applications = @applications.where('created_at >= ?', params[:date_from])
    end
    if params[:date_to].present?
      @applications = @applications.where('created_at <= ?', params[:date_to])
    end

    # Filter by minimum amount
    if params[:amount_min].present?
      @applications = @applications.where('amount_requested >= ?', params[:amount_min])
    end

    @available_years = Application.distinct.pluck(:application_year).compact.sort.reverse
    @status_options = Application::STATUSES.map { |s| [s.humanize, s] }

    # Define available columns with human-readable names
    @available_columns = {
      'first_name' => 'First Name',
      'last_name' => 'Last Name',
      'email_address' => 'Email',
      'tribal_id' => 'Tribal ID',
      'application_key' => 'App Key',
      'application_year' => 'Year',
      'status' => 'Status',
      'class_standing' => 'Class Standing',
      'college_name' => 'School',
      'field_of_study' => 'Major',
      'gpa' => 'GPA',
      'amount_requested' => 'Requested',
      'amount_awarded' => 'Awarded',
      'arpa_amount_awarded' => 'ARPA Awarded',
      'board_status' => 'Board Status',
      'created_at' => 'Submitted'
    }

    # Default visible columns (can be customized via params or user preferences)
    @visible_columns = params[:columns].present? ?
      params[:columns].split(',') :
      %w[first_name last_name email_address application_key status class_standing college_name gpa amount_requested amount_awarded]
  end

  # Status/progress overview - summary view
  def index
    @verifications = VerificationTemplate.includes(:application)
                                          .joins("LEFT JOIN applications ON applications.application_key = verification_templates.application_key")

    # Default: show non-archived (current) templates
    if params[:archived] == 'true'
      @verifications = @verifications.archived
    else
      @verifications = @verifications.current
    end

    # Filter by verification status
    if params[:status].present?
      @verifications = @verifications.where(verification_status: params[:status])
    end

    # Search by tribal_id or application_key
    if params[:search].present?
      term = "%#{params[:search]}%"
      @verifications = @verifications.where(
        'verification_templates.application_key ILIKE :t OR applications.tribal_id ILIKE :t',
        t: term
      )
    end

    # Order by application submission date (oldest first by default)
    sort_direction = params[:direction] || 'asc'
    @verifications = @verifications.order("applications.created_at #{sort_direction}")

    @status_options = [
      ['Not Started', 'not_started'],
      ['In Progress', 'in_progress'],
      ['Completed', 'completed']
    ]
  end

  # Individual verification view
  def show
    @application = Application.find_by(application_key: @verification_template.application_key)
    @checklist_items = @verification_template.checklist_items
  end

  # Update verification checklist items
  def update
    if params[:checklist_item].present?
      # Update single checklist item
      item_key = params[:checklist_item][:key]
      checked = params[:checklist_item][:checked] == 'true'
      notes = params[:checklist_item][:notes]
      verified_by = current_staff_identifier

      @verification_template.update_item(item_key, checked: checked, verified_by: verified_by, notes: notes)

      respond_to do |format|
        format.json { render json: { success: true, completion_percentage: @verification_template.completion_percentage } }
        format.html { redirect_to admin_verification_path(@verification_template), notice: 'Checklist updated.' }
      end
    elsif params[:complete] == 'true'
      # Mark verification as complete
      if @verification_template.complete!(completed_by: current_staff_identifier)
        respond_to do |format|
          format.json { render json: { success: true } }
          format.html { redirect_to admin_verification_path(@verification_template), notice: 'Verification completed!' }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, error: 'Not all required items are complete' }, status: :unprocessable_entity }
          format.html { redirect_to admin_verification_path(@verification_template), alert: 'Cannot complete - not all required items are checked.' }
        end
      end
    elsif params[:archive] == 'true'
      @verification_template.archive!
      redirect_to admin_verifications_path, notice: 'Verification archived.'
    elsif params[:unarchive] == 'true'
      @verification_template.unarchive!
      redirect_to admin_verifications_path, notice: 'Verification unarchived.'
    else
      # Update other fields (notes, recommended amounts)
      if @verification_template.update(verification_template_params)
        respond_to do |format|
          format.json { render json: { success: true } }
          format.html { redirect_to admin_verification_path(@verification_template), notice: 'Verification updated.' }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, errors: @verification_template.errors.full_messages }, status: :unprocessable_entity }
          format.html { render :show, status: :unprocessable_entity }
        end
      end
    end
  end

  private

  def set_verification_template
    @verification_template = VerificationTemplate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_verifications_path, alert: 'Verification template not found.'
  end

  def verification_template_params
    params.require(:verification_template).permit(
      :staff_notes, :issues_found, :recommended_award_amount, :recommended_arpa_amount, :award_notes
    )
  end

  def current_staff_identifier
    # TODO: Replace with actual authentication when implemented
    'staff@sta.org'
  end
end
