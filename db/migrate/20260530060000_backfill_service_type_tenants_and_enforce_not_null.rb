require "bcrypt"
require "securerandom"

class BackfillServiceTypeTenantsAndEnforceNotNull < ActiveRecord::Migration[8.1]
  LEGACY_EMAIL = "legacy-service-centre@example.invalid"

  def up
    legacy_id = ensure_legacy_service_centre_id

    execute <<~SQL.squish
      WITH inferred AS (
        SELECT st.id, MIN(sr.serviced_by) AS service_centre_id
        FROM service_types st
        INNER JOIN service_records sr ON sr.service_type_id = st.id
        INNER JOIN users u ON u.id = sr.serviced_by
        WHERE st.service_centre_id IS NULL
          AND u.role = 'service_centre'
        GROUP BY st.id
        HAVING COUNT(DISTINCT sr.serviced_by) = 1
      )
      UPDATE service_types st
      SET service_centre_id = inferred.service_centre_id
      FROM inferred
      WHERE st.id = inferred.id
        AND NOT EXISTS (
          SELECT 1
          FROM service_types existing
          WHERE existing.service_centre_id = inferred.service_centre_id
            AND lower(existing.name) = lower(st.name)
            AND existing.id != st.id
        )
    SQL

    execute <<~SQL.squish
      UPDATE service_types
      SET service_centre_id = #{legacy_id}
      WHERE service_centre_id IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE service_records sr
      SET serviced_by = #{legacy_id}
      FROM service_types st
      WHERE sr.service_type_id = st.id
        AND st.service_centre_id = #{legacy_id}
        AND sr.serviced_by IS NULL
    SQL

    change_column_null :service_types, :service_centre_id, false
  end

  def down
    change_column_null :service_types, :service_centre_id, true
  end

  private

  def ensure_legacy_service_centre_id
    existing_id = select_value(<<~SQL.squish)
      SELECT id
      FROM users
      WHERE email = #{quote(LEGACY_EMAIL)}
      LIMIT 1
    SQL
    return existing_id if existing_id.present?

    password_digest = BCrypt::Password.create(SecureRandom.hex(32))
    timestamp = quote(Time.current)

    select_value(<<~SQL.squish)
      INSERT INTO users (name, email, password_digest, role, created_at, updated_at)
      VALUES ('Legacy Service Centre', #{quote(LEGACY_EMAIL)}, #{quote(password_digest)}, 'service_centre', #{timestamp}, #{timestamp})
      RETURNING id
    SQL
  end
end
