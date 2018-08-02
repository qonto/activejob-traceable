require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :active_job do
  require 'activejob/traceable/traceable'
  require 'activejob/traceable/logging_patch'
  ActiveJob::Base.send(:include, ActiveJob::Traceable)
  ActiveJob::Base.send(:include, ActiveJob::Traceable::LoggingPatch)
end

module ActiveJob
  module Traceable
    extend self

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
