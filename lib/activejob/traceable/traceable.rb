# frozen_string_literal: true

module ActiveJob
  module Traceable
    extend ActiveSupport::Concern

    included do
      attr_accessor :tracing_info

      def initialize(*arguments)
        super(*arguments)

        @tracing_info = Traceable.tracing_info_getter.call.deep_stringify_keys
      end

      def serialize
        super.merge!('tracing_info' => tracing_info)
      end

      def deserialize(job_data)
        super(job_data)

        if job_data['tracing_info'].is_a?(Hash)
          self.tracing_info = job_data['tracing_info']
        end

        Traceable.tracing_info_setter.call(tracing_info.with_indifferent_access)
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
