# frozen_string_literal: true

module ActiveJob
  module Traceable
    extend ActiveSupport::Concern

    included do
      attr_accessor :actor_id, :correlation_id, :trace_id

      def initialize(*arguments)
        super(*arguments)

        @actor_id = Traceable.actor_id_getter.call if Traceable.actor_id_getter.respond_to?(:call)
        @correlation_id = Traceable.correlation_id_getter.call if Traceable.correlation_id_getter.respond_to?(:call)
        @trace_id = Traceable.trace_id_getter.call if Traceable.trace_id_getter.respond_to?(:call)
      end

      def serialize
        super.merge!(
          actor_id: actor_id,
          correlation_id: correlation_id,
          trace_id: trace_id,
        )
      end

      def deserialize(job_data)
        super(job_data)

        self.actor_id = job_data['actor_id']
        self.correlation_id = job_data['correlation_id']
        self.trace_id = job_data['trace_id']

        Traceable.actor_id_setter.call(actor_id) if Traceable.actor_id_setter.respond_to?(:call)
        Traceable.correlation_id_setter.call(correlation_id) if Traceable.correlation_id_setter.respond_to?(:call)
        Traceable.trace_id_setter.call(trace_id) if Traceable.trace_id_setter.respond_to?(:call)
      end
    end

    class << self
      attr_accessor :actor_id_getter, :correlation_id_getter, :trace_id_getter
      attr_accessor :actor_id_setter, :correlation_id_setter, :trace_id_setter
    end
  end
end
