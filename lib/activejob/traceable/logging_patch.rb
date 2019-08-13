# frozen_string_literal: true

module ActiveJob
  module Traceable
    module LoggingPatch
      extend ActiveSupport::Concern

      included do
        private

        def tag_logger(*tags)
          if ActiveJob::Traceable.tracing_info_getter.respond_to?(:call)
            tags << ActiveJob::Traceable.tracing_info_getter.call
          end

          if logger.respond_to?(:tagged)
            tags.unshift 'ActiveJob' unless logger_tagged_by_active_job?
            logger.tagged(*tags) { yield }
          else
            yield
          end
        end
      end
    end
  end
end
