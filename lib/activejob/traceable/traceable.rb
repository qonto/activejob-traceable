# frozen_string_literal: true

module ActiveJob
  module Traceable
    extend ActiveSupport::Concern

    included do
      attr_accessor :tracing_info

      def initialize(*args)
        super(*args)

        @tracing_info = Traceable.tracing_info_getter.call.deep_stringify_keys
      end
      ruby2_keywords :initialize if respond_to?(:ruby2_keywords, true)

      def serialize
        add_telemetry_data!
        super.merge!('tracing_info' => tracing_info)
      end

      def deserialize(job_data)
        super(job_data)

        if job_data['tracing_info'].is_a?(Hash)
          self.tracing_info = job_data['tracing_info']
        end

        add_telemetry_data!

        Traceable.tracing_info_setter.call(tracing_info.with_indifferent_access)
      end
    end

    private

    def add_telemetry_data!
      if ENV["OTEL_EXPORTER_OTLP_ENDPOINT"].present?
        current_span = OpenTelemetry::Trace.current_span
        @tracing_info["trace_id"] = current_span.context.trace_id.unpack1("H*")
        @tracing_info["span_id"] = current_span.context.span_id.unpack1("H*")
      end
    end

    class << self
      def tracing_info_getter
        @tracing_info_getter || -> { {} }
      end

      def tracing_info_setter
        @tracing_info_setter || -> {}
      end
    end
  end
end
