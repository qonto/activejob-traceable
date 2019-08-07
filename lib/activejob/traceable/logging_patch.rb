# frozen_string_literal: true

module ActiveJob
  module Traceable
    module LoggingPatch
      extend ActiveSupport::Concern

      included do
        private

        def tag_logger(*tags)
          tags = append_custom_tags(tags)

          if logger.respond_to?(:tagged)
            tags.unshift 'ActiveJob' unless logger_tagged_by_active_job?
            logger.tagged(*tags) { yield }
          else
            yield
          end
        end

        def append_custom_tags(tags)
          traceable = ActiveJob::Traceable

          tags << traceable.actor_id_getter.call if traceable.actor_id_getter.respond_to?(:call)
          tags << traceable.correlation_id_getter.call if traceable.correlation_id_getter.respond_to?(:call)
          tags << traceable.trace_id_getter.call if traceable.trace_id_getter.respond_to?(:call)

          tags
        end
      end
    end
  end
end
