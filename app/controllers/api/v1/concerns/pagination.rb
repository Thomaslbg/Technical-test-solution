# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module Pagination
        include Pagy::Backend

        extend ActiveSupport::Concern

        def paginate(serializer, resources, options: {})
          paginated_resources = page_all? ? resources : paginate_resources(resources)
          meta_options = paginated_resources_meta(paginated_resources)

          serializer.new(paginated_resources, meta_options.merge(options).with_indifferent_access)
        end

        private

        def paginate_resources(resources)
          per = per_param(resources)

          if resources.is_a?(Array)
            @pagy, @ressources = pagy_array(resources, page: page_param, items: per)
          else
            @pagy, @ressources = pagy(resources, page: page_param, items: per)
          end

          @ressources
        end

        def paginated_resources_meta(resources)
          {
            meta: {
              current_page: @pagy&.page || 1,
              next_page: @pagy&.next,
              per_page: @pagy&.items || resources&.length,
              prev_page: @pagy&.prev,
              total_pages: @pagy&.pages || 1,
              total_count: @pagy&.count || resources&.length
            }
          }
        end

        def page_all?
          params[:page] == 'all'
        end

        def page_param
          page_all? || params[:page].blank? ? 1 : params[:page]
        end

        def per_param(resources)
          if page_all?
            return resources.length.zero? ? 1 : resources.length
          end

          params[:per] || 25
        end
      end
    end
  end
end
