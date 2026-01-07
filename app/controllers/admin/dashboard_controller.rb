class Admin::DashboardController < ApplicationController
  # TODO: Add authentication and authorization before production
  # before_action :authenticate_admin!

  def index
    # Dashboard statistics
    @total_applications = Application.count
    @pending_applications = Application.where(status: ['submitted', 'under_review']).count
    @approved_applications = Application.where(status: 'approved').count
    @rejected_applications = Application.where(status: 'rejected').count

    # Recent applications (last 15) with verification templates
    @recent_applications = Application.includes(:verification_template)
                                      .order(created_at: :desc).limit(15)

    # Recent students - those who have applications in the recent applications list
    recent_tribal_ids = @recent_applications.pluck(:tribal_id).uniq
    @recent_students = Student.where(tribal_id: recent_tribal_ids)
                              .includes(applications: :verification_template)
                              .includes(:student_financial_trackings)
                              .limit(10)

    # Applications by status for quick overview
    @applications_by_status = Application.group(:status).count

    # Monthly application trends (simplified for now)
    @monthly_applications = {}
  end
end