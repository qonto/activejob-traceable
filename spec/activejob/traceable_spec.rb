require 'spec_helper'

RSpec.describe 'ActiveJobTraceableJob', type: :job do
  class CurrentScope
    cattr_accessor :trace_id
  end

  class ActiveJobTraceableJob < ActiveJob::Base; end

  before do
    ActiveJob::Traceable.trace_id_getter = -> { CurrentScope.trace_id }
    ActiveJob::Traceable.trace_id_setter = ->(trace_id) { CurrentScope.trace_id = trace_id }
  end

  describe 'trace_id' do
    let(:current_trace_id) { 'current-trace-id' }

    before do
      CurrentScope.trace_id = current_trace_id
    end

    subject(:job) { ActiveJobTraceableJob.perform_later }

    describe 'accessor' do
      it 'has trace_id value' do
        expect(job.trace_id).to eq('current-trace-id')
      end
    end

    describe 'serialize' do
      it 'has trace_id value' do
        expect(job.serialize).to include(trace_id: 'current-trace-id')
      end
    end

    describe 'deserialize' do
      before do
        CurrentScope.trace_id = nil
      end

      let(:current_trace_id) { 'changed-trace-id' }
      let(:job_data) do
        { 'trace_id' => 'changed-trace-id' }
      end

      it 'has trace_id value' do
        job.deserialize(job_data)
        expect(job.trace_id).to eq('changed-trace-id')
      end

      it 'sets trace_id to CurrentScope' do
        job.deserialize(job_data)
        expect(CurrentScope.trace_id).to eq('changed-trace-id')
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
      CurrentScope.trace_id = current_trace_id
    end

    let(:current_trace_id) { 'current-trace-id' }

    it 'uses trace_id as tag' do
      ActiveJobTraceableJob.perform_later
      expect(logger.messages).to include(current_trace_id)
    end
  end
end
