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

    def actor_id_setter=(lambda)
      raise 'Actor ID setter should be callable' unless lambda.respond_to?(:call)

      @actor_id_setter = lambda
    end

    def actor_id_getter=(lambda)
      raise 'Actor ID getter should be callable' unless lambda.respond_to?(:call)

      @actor_id_getter = lambda
    end

    def correlation_id_setter=(lambda)
      raise 'Correlation ID setter should be callable' unless lambda.respond_to?(:call)

      @correlation_id_setter = lambda
    end

    def correlation_id_getter=(lambda)
      raise 'Correlation ID getter should be callable' unless lambda.respond_to?(:call)

      @correlation_id_getter = lambda
    end

    def trace_id_setter=(lambda)
      raise 'Trace ID setter should be callable' unless lambda.respond_to?(:call)

      @trace_id_setter = lambda
    end

    def trace_id_getter=(lambda)
      raise 'Trace ID getter should be callable' unless lambda.respond_to?(:call)

      @trace_id_getter = lambda
    end
  end
end
