require 'spec_helper'

RSpec.describe 'ActiveJobTraceableJob', type: :job do
  class CurrentScope
    cattr_accessor :actor_id, :correlation_id, :trace_id
  end

  class ActiveJobTraceableJob < ActiveJob::Base; end

  before do
    ActiveJob::Traceable.actor_id_getter = -> { CurrentScope.actor_id }
    ActiveJob::Traceable.actor_id_setter = ->(id) { CurrentScope.actor_id = id }

    ActiveJob::Traceable.correlation_id_getter = -> { CurrentScope.correlation_id }
    ActiveJob::Traceable.correlation_id_setter = ->(id) { CurrentScope.correlation_id = id }

    ActiveJob::Traceable.trace_id_getter = -> { CurrentScope.trace_id }
    ActiveJob::Traceable.trace_id_setter = ->(id) { CurrentScope.trace_id = id }
  end

  describe 'actor_id' do
    subject(:job) { ActiveJobTraceableJob.perform_later }

    let(:current_actor_id) { 'current-actor-id' }

    before do
      CurrentScope.actor_id = current_actor_id
    end

    describe 'accessor' do
      it 'has actor_id value' do
        expect(job.actor_id).to eq('current-actor-id')
      end
    end

    describe 'serialize' do
      it 'has actor_id value' do
        expect(job.serialize).to include(actor_id: 'current-actor-id')
      end
    end

    describe 'deserialize' do
      before do
        CurrentScope.actor_id = nil
      end

      let(:current_actor_id) { 'changed-actor-id' }
      let(:job_data) do
        { 'actor_id' => 'changed-actor-id' }
      end

      it 'has actor_id value' do
        job.deserialize(job_data)
        expect(job.actor_id).to eq('changed-actor-id')
      end

      it 'sets actor_id to CurrentScope' do
        job.deserialize(job_data)
        expect(CurrentScope.actor_id).to eq('changed-actor-id')
      end
    end
  end

  describe 'correlation_id' do
    subject(:job) { ActiveJobTraceableJob.perform_later }

    let(:current_correlation_id) { 'current-correlation-id' }

    before do
      CurrentScope.correlation_id = current_correlation_id
    end

    describe 'accessor' do
      it 'has correlation_id value' do
        expect(job.correlation_id).to eq('current-correlation-id')
      end
    end

    describe 'serialize' do
      it 'has correlation_id value' do
        expect(job.serialize).to include(correlation_id: 'current-correlation-id')
      end
    end

    describe 'deserialize' do
      before do
        CurrentScope.correlation_id = nil
      end

      let(:current_correlation_id) { 'changed-correlation-id' }
      let(:job_data) do
        { 'correlation_id' => 'changed-correlation-id' }
      end

      it 'has correlation_id value' do
        job.deserialize(job_data)
        expect(job.correlation_id).to eq('changed-correlation-id')
      end

      it 'sets correlation_id to CurrentScope' do
        job.deserialize(job_data)
        expect(CurrentScope.correlation_id).to eq('changed-correlation-id')
      end
    end
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
