class Admin::DashboardController < ApplicationController
  # TODO: Add authentication and authorization before production
  # before_action :authenticate_admin!
  
  def index
    # Dashboard statistics
    @total_applications = Application.count
    @pending_applications = Application.where(status: ['submitted', 'under_review']).count
    @approved_applications = Application.where(status: 'approved').count
    @rejected_applications = Application.where(status: 'rejected').count

    # Recent applications (last 10)
    @recent_applications = Application.order(created_at: :desc).limit(10)

    # Applications by status for quick overview
    @applications_by_status = Application.group(:status).count

    # Monthly application trends (simplified for now)
    @monthly_applications = {}
  end
end