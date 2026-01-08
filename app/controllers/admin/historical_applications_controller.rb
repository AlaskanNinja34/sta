# app/controllers/admin/historical_applications_controller.rb
# Admin controller for importing and managing historical paper applications

class Admin::HistoricalApplicationsController < ApplicationController
  before_action :set_historical_application, only: %i[show edit update destroy]

  def index
    @historical_applications = HistoricalApplication.includes(:student)

    # Search by tribal_id, school name, or student name
    if params[:search].present?
      term = "%#{params[:search]}%"
      @historical_applications = @historical_applications
        .left_joins(:student)
        .where(
          'historical_applications.tribal_id ILIKE :t OR historical_applications.school_name ILIKE :t OR students.first_name ILIKE :t OR students.last_name ILIKE :t',
          t: term
        )
    end

    # Filter by year
    if params[:year].present?
      @historical_applications = @historical_applications.for_year(params[:year].to_i)
    end

    # Filter by education level
    if params[:education_level].present?
      @historical_applications = @historical_applications.where(education_level: params[:education_level])
    end

    @historical_applications = @historical_applications.order(application_year: :desc, created_at: :desc)

    # Get available years for filter dropdown
    @available_years = HistoricalApplication.distinct.pluck(:application_year).compact.sort.reverse
  end

  def show
    @student = @historical_application.student
    @financial_record = StudentFinancialTracking.find_by(application_key: @historical_application.application_key)
  end

  def new
    @historical_application = HistoricalApplication.new
    # Pre-fill tribal_id if coming from student profile
    @historical_application.tribal_id = params[:tribal_id] if params[:tribal_id].present?
  end

  def create
    @historical_application = HistoricalApplication.new(historical_application_params)
    @historical_application.entry_date = Date.current
    @historical_application.entered_by_staff_id = current_staff_identifier

    # Find or create student by tribal_id
    find_or_create_student

    if @historical_application.save
      redirect_to admin_historical_application_path(@historical_application),
                  notice: "Historical application imported successfully. Application Key: #{@historical_application.application_key}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @historical_application.update(historical_application_params)
      # Recalculate student totals in case amount changed
      @historical_application.student&.recalculate_lifetime_totals!

      redirect_to admin_historical_application_path(@historical_application),
                  notice: 'Historical application updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    student = @historical_application.student
    @historical_application.destroy

    # Recalculate student totals after deletion
    student&.recalculate_lifetime_totals!

    redirect_to admin_historical_applications_path,
                notice: 'Historical application deleted.'
  end

  private

  def set_historical_application
    @historical_application = HistoricalApplication.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_historical_applications_path, alert: 'Historical application not found.'
  end

  def historical_application_params
    params.require(:historical_application).permit(
      :tribal_id,
      :first_name,
      :last_name,
      :application_year,
      :school_name,
      :education_level,
      :amount_requested,
      :amount_awarded,
      :regular_amount,
      :arpa_amount,
      :award_type,
      :notes
    )
  end

  # Find existing student by tribal_id or create a new one
  def find_or_create_student
    return if @historical_application.tribal_id.blank?

    student = Student.find_by(tribal_id: @historical_application.tribal_id)

    unless student
      # Create new student profile from historical application data
      student = Student.create(
        tribal_id: @historical_application.tribal_id,
        first_name: @historical_application.first_name,
        last_name: @historical_application.last_name,
        status: 'active'
      )
    end
  end

  def current_staff_identifier
    # TODO: Replace with actual authentication when implemented
    'staff@sta.org'
  end
end
