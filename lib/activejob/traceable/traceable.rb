# frozen_string_literal: true

module ActiveJob
  module Traceable
    extend ActiveSupport::Concern

    included do
      attr_accessor :tracing_info

      def initialize(*arguments)
        super(*arguments)

        @tracing_info = Traceable.tracing_info_getter.call if Traceable.tracing_info_getter.respond_to?(:call)
      end

      def serialize
        super.merge!(tracing_info: tracing_info)
      end

      def deserialize(job_data)
        super(job_data)

        self.tracing_info = job_data['tracing_info']

        Traceable.tracing_info_setter.call(tracing_info) if Traceable.tracing_info_setter.respond_to?(:call)
      end
    end

    class << self
      attr_accessor :tracing_info_getter, :tracing_info_setter
    end
  end
end
