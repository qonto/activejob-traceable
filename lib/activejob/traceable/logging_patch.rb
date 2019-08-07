# frozen_string_literal: true

module ActiveJob
  module Traceable
    module LoggingPatch
      extend ActiveSupport::Concern

      included do
        private

        def tag_logger(*tags)
          if ActiveJob::Traceable.trace_id_getter.respond_to?(:call)
            tags << ActiveJob::Traceable.trace_id_getter.call # add custom tag
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
