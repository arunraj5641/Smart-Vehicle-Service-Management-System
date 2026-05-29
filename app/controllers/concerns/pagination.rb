module Pagination
  extend ActiveSupport::Concern

  def paginate(scope)
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    paginated = scope.offset((page - 1) * per_page).limit(per_page)

    meta = {
      page: page,
      per_page: per_page,
      total: scope.count
    }

    [paginated, meta]
  end
end