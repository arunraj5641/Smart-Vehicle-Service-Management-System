class ScopeServiceTypeNameUniquenessToServiceCentre < ActiveRecord::Migration[8.1]
  def up
    remove_unique_constraint :service_types, name: "service_types_name_key"

    add_index :service_types,
              "service_centre_id, lower(name)",
              unique: true,
              name: "index_service_types_on_service_centre_id_and_lower_name"
  end

  def down
    remove_index :service_types, name: "index_service_types_on_service_centre_id_and_lower_name"

    add_unique_constraint :service_types, :name, name: "service_types_name_key"
  end
end
