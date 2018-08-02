module ActiveJob
  module Traceable
    extend ActiveSupport::Concern

    included do
      attr_accessor :trace_id

      def initialize(*arguments)
        super(*arguments)
        if Traceable.trace_id_getter.respond_to?(:call)
          @trace_id = Traceable.trace_id_getter.call
        end
      end

      def serialize
        super.merge!(trace_id: trace_id)
      end

      def deserialize(job_data)
        super(job_data)
        self.trace_id = job_data['trace_id']
        if Traceable.trace_id_setter.respond_to?(:call)
          Traceable.trace_id_setter.call(self.trace_id)
        end
      end
    end

    class << self
      attr_accessor :trace_id_getter
      attr_accessor :trace_id_setter
    end
  end
end
