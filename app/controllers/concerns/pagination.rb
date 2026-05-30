module Pagination
  extend ActiveSupport::Concern

  def paginate(scope)
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i
    total_count = scope.count
    total_pages = (total_count.to_f / per_page).ceil

    paginated = scope.offset((page - 1) * per_page).limit(per_page)

    meta = {
      pagination: {
        current_page: page,
        next_page: page < total_pages ? page + 1 : nil,
        prev_page: page > 1 ? page - 1 : nil,
        total_pages: total_pages,
        total_count: total_count,
        per_page: per_page
      }
    }

    [paginated, meta]
  end
end