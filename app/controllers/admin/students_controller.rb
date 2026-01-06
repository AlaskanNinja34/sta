# app/controllers/admin/students_controller.rb
# Admin controller for managing student profiles and lifetime tracking

class Admin::StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update]

  def new
    @student = Student.new
    # Pre-fill tribal_id if coming from historical application
    @student.tribal_id = params[:tribal_id] if params[:tribal_id].present?
  end

  def create
    @student = Student.new(student_params)
    @student.tribal_id = params[:student][:tribal_id] if params[:student][:tribal_id].present?

    if @student.save
      # Recalculate totals in case there are existing historical applications
      @student.recalculate_lifetime_totals!
      redirect_to admin_student_path(@student), notice: 'Student profile created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @students = Student.all

    # Search by name or tribal_id
    if params[:search].present?
      term = "%#{params[:search]}%"
      @students = @students.where(
        'first_name ILIKE :t OR last_name ILIKE :t OR tribal_id ILIKE :t OR email_address ILIKE :t',
        t: term
      )
    end

    # Filter by limit warnings
    case params[:approaching_limit]
    when 'lifetime'
      @students = @students.approaching_lifetime_limit
    when 'undergrad'
      @students = @students.approaching_undergrad_limit
    when 'grad'
      @students = @students.approaching_grad_limit
    end

    @students = @students.order(:last_name, :first_name)
  end

  def show
    @applications = @student.applications.order(application_year: :desc)
    @historical_applications = @student.historical_applications.order(application_year: :desc)
    @financial_records = @student.student_financial_trackings.order(award_year: :desc)

    # Calculate totals
    @undergrad_remaining = @student.remaining_undergrad_eligibility
    @grad_remaining = @student.remaining_grad_eligibility
  end

  def edit; end

  def update
    if @student.update(student_params)
      redirect_to admin_student_path(@student), notice: 'Student profile updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Recalculate lifetime totals for a student
  def recalculate_totals
    @student = Student.find(params[:id])
    @student.recalculate_lifetime_totals!
    redirect_to admin_student_path(@student), notice: 'Lifetime totals recalculated.'
  end

  private

  def set_student
    @student = Student.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_students_path, alert: 'Student not found.'
  end

  def student_params
    permitted = %i[
      first_name last_name middle_initial date_of_birth
      email_address permanent_phone
      mailing_address_permanent city state zip_code
      lifetime_award_notes
    ]
    # Allow tribal_id only on create (not update)
    permitted << :tribal_id if action_name == 'create'
    params.require(:student).permit(permitted)
  end
end
