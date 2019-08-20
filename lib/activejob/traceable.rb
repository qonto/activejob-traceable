# frozen_string_literal: true

require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :active_job do
  require 'activejob/traceable/traceable'
  require 'activejob/traceable/logging_patch'
  ActiveJob::Base.public_send(:include, ActiveJob::Traceable)
  ActiveJob::Base.public_send(:include, ActiveJob::Traceable::LoggingPatch)
end

module ActiveJob
  module Traceable
    module_function

    def tracing_info_getter=(lambda)
      if lambda
        raise 'Tracing info getter should be callable' unless lambda.respond_to?(:call)
        raise 'Tracing info getter should contain a hash' unless lambda.call.is_a?(Hash)

        @tracing_info_getter = lambda
      else
        # Resets the value
        @tracing_info_getter = nil
      end
    end

    def tracing_info_setter=(lambda)
      if lambda
        raise 'Tracing info setter should be callable' unless lambda.respond_to?(:call)

        @tracing_info_setter = lambda
      else
        # Resets the value
        @tracing_info_setter = nil
      end
    end
  end
end
