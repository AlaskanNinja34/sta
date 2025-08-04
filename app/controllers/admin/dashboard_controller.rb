class Admin::DashboardController < ApplicationController
  # TODO: Add authentication and authorization before production
  # before_action :authenticate_admin!
  
  def index
    # Dashboard statistics
    @total_applications = ScholarshipApplication.count
    @pending_applications = ScholarshipApplication.where(status: ['submitted', 'under_review']).count
    @approved_applications = ScholarshipApplication.where(status: 'approved').count
    @rejected_applications = ScholarshipApplication.where(status: 'rejected').count
    
    # Recent applications (last 10)
    @recent_applications = ScholarshipApplication.order(created_at: :desc).limit(10)
    
    # Applications by status for quick overview
    @applications_by_status = ScholarshipApplication.group(:status).count
    
    # Monthly application trends (simplified for now)
    @monthly_applications = {}
  end
end