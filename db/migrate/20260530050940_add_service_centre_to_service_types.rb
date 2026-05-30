class AddServiceCentreToServiceTypes < ActiveRecord::Migration[8.1]
  def change
    add_reference :service_types, :service_centre, foreign_key: { to_table: :users }
  end
end
