# db/migrate/20260106000001_add_amount_breakdown_to_historical_applications.rb
# Add separate regular and ARPA amount fields for combined awards

class AddAmountBreakdownToHistoricalApplications < ActiveRecord::Migration[8.0]
  def change
    # For combined awards, we need to track how much was regular vs ARPA
    # Regular amounts count toward lifetime limits, ARPA amounts do not
    add_column :historical_applications, :regular_amount, :decimal, precision: 10, scale: 2
    add_column :historical_applications, :arpa_amount, :decimal, precision: 10, scale: 2
  end
end
