# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ActiveJobTraceableJob', type: :job do
  class CurrentScope
    cattr_accessor :first_attribute, :second_attribute
  end

  class ActiveJobTraceableJob < ActiveJob::Base; end

  before do
    ActiveJob::Traceable.tracing_info_getter = lambda do
      {
        first_attribute: CurrentScope.first_attribute,
        second_attribute: CurrentScope.second_attribute
      }
    end

    ActiveJob::Traceable.tracing_info_setter = lambda do |attributes|
      CurrentScope.first_attribute = attributes[:first_attribute]
      CurrentScope.second_attribute = attributes[:second_attribute]
    end
  end

  describe 'tracing_info' do
    subject(:job) { ActiveJobTraceableJob.perform_later }

    before do
      CurrentScope.first_attribute = 'first_attribute_value'
      CurrentScope.second_attribute = 'second_attribute_value'
    end

    describe 'accessor' do
      it 'has tracing_info value' do
        expect(job.tracing_info).to eq(
          first_attribute: 'first_attribute_value',
          second_attribute: 'second_attribute_value',
        )
      end
    end

    describe 'serialize' do
      it 'has tracing_info value' do
        expect(job.serialize).to include(
          tracing_info: {
            first_attribute: 'first_attribute_value',
            second_attribute: 'second_attribute_value'
          },
        )
      end
    end

    describe 'deserialize' do
      before do
        CurrentScope.first_attribute = nil
        CurrentScope.second_attribute = nil
      end

      let(:current_actor_id) { 'changed-actor-id' }
      let(:job_data) do
        {
          'tracing_info' => {
            first_attribute: 'updated_first_value',
            second_attribute: 'updated_second_value'
          }
        }
      end

      it 'has tracing_info value' do
        job.deserialize(job_data)

        expect(job.tracing_info).to eq(
          first_attribute: 'updated_first_value',
          second_attribute: 'updated_second_value',
        )
      end

      it 'sets tracing_info to CurrentScope', :aggregate_failures do
        job.deserialize(job_data)

        expect(CurrentScope.first_attribute).to eq('updated_first_value')
        expect(CurrentScope.second_attribute).to eq('updated_second_value')
      end
    end
  end

  describe 'Logger' do
    class TestLogger < ActiveSupport::Logger
      def initialize
        @file = StringIO.new
        super(@file)
      end

      def messages
        @file.rewind
        @file.read
      end
    end

    let(:logger) { ActiveSupport::TaggedLogging.new(TestLogger.new) }

    before do
      ActiveJob::Base.logger = logger
      CurrentScope.first_attribute = 'first_attribute_value'
      CurrentScope.second_attribute = 'second_attribute_value'
    end

    it 'uses tracing_info as tags' do
      ActiveJobTraceableJob.perform_later

      expect(logger.messages).to include(
        '{:first_attribute=>"first_attribute_value", :second_attribute=>"second_attribute_value"}',
      )
    end
  end
end
