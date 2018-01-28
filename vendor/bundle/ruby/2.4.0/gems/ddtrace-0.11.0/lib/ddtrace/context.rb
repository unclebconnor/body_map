require 'thread'

module Datadog
  # \Context is used to keep track of a hierarchy of spans for the current
  # execution flow. During each logical execution, the same \Context is
  # used to represent a single logical trace, even if the trace is built
  # asynchronously.
  #
  # A single code execution may use multiple \Context if part of the execution
  # must not be related to the current tracing. As example, a delayed job may
  # compose a standalone trace instead of being related to the same trace that
  # generates the job itself. On the other hand, if it's part of the same
  # \Context, it will be related to the original trace.
  #
  # This data structure is thread-safe.
  class Context
    # Initialize a new thread-safe \Context.
    def initialize(options = {})
      @mutex = Mutex.new
      reset(options)
    end

    def reset(options = {})
      @trace = []
      @parent_trace_id = options.fetch(:trace_id, nil)
      @parent_span_id = options.fetch(:span_id, nil)
      @sampled = options.fetch(:sampled, false)
      @sampling_priority = options.fetch(:sampling_priority, nil)
      @finished_spans = 0
      @current_span = nil
    end

    def trace_id
      @mutex.synchronize do
        @parent_trace_id
      end
    end

    def span_id
      @mutex.synchronize do
        @parent_span_id
      end
    end

    def sampling_priority
      @mutex.synchronize do
        @sampling_priority
      end
    end

    def sampling_priority=(priority)
      @mutex.synchronize do
        @sampling_priority = priority
      end
    end

    # Return the last active span that corresponds to the last inserted
    # item in the trace list. This cannot be considered as the current active
    # span in asynchronous environments, because some spans can be closed
    # earlier while child spans still need to finish their traced execution.
    def current_span
      @mutex.synchronize do
        return @current_span
      end
    end

    def set_current_span(span)
      @current_span = span
      if span
        @parent_trace_id = span.trace_id
        @parent_span_id = span.span_id
        @sampled = span.sampled
      else
        @parent_span_id = nil
      end
    end

    # Add a span to the context trace list, keeping it as the last active span.
    def add_span(span)
      @mutex.synchronize do
        set_current_span(span)
        @trace << span
        span.context = self
      end
    end

    # Mark a span as a finished, increasing the internal counter to prevent
    # cycles inside _trace list.
    def close_span(span)
      @mutex.synchronize do
        @finished_spans += 1
        # Current span is only meaningful for linear tree-like traces,
        # in other cases, this is just broken and one should rely
        # on per-instrumentation code to retrieve handle parent/child relations.
        set_current_span(span.parent)
        return if span.tracer.nil?
        return unless Datadog::Tracer.debug_logging
        if span.parent.nil? && !check_finished_spans
          opened_spans = @trace.length - @finished_spans
          Datadog::Tracer.log.debug("root span #{span.name} closed but has #{opened_spans} unfinished spans:")
          @trace.each do |s|
            Datadog::Tracer.log.debug("unfinished span: #{s}") unless s.finished?
          end
        end
      end
    end

    # Returns if the trace for the current Context is finished or not.
    # Low-level internal function, not thread-safe.
    def check_finished_spans
      @finished_spans > 0 && @trace.length == @finished_spans
    end

    # Returns if the trace for the current Context is finished or not. A \Context
    # is considered finished if all spans in this context are finished.
    def finished?
      @mutex.synchronize do
        return check_finished_spans
      end
    end

    # Returns true if the context is sampled, that is, if it should be kept
    # and sent to the trace agent.
    def sampled?
      @mutex.synchronize do
        return @sampled
      end
    end

    # Returns both the trace list generated in the current context and
    # if the context is sampled or not. It returns nil, nil if the ``Context`` is
    # not finished. If a trace is returned, the \Context will be reset so that it
    # can be re-used immediately.
    #
    # This operation is thread-safe.
    def get
      @mutex.synchronize do
        return nil, nil unless check_finished_spans

        trace = @trace
        sampled = @sampled
        attach_sampling_priority if sampled && @sampling_priority

        reset
        return trace, sampled
      end
    end

    # Return a string representation of the context.
    def to_s
      @mutex.synchronize do
        # rubocop:disable Metrics/LineLength
        "Context(trace.length:#{@trace.length},sampled:#{@sampled},finished_spans:#{@finished_spans},current_span:#{@current_span})"
      end
    end

    def attach_sampling_priority
      @trace.first.set_metric(
        Ext::DistributedTracing::SAMPLING_PRIORITY_KEY,
        @sampling_priority
      )
    end

    private :reset
    private :check_finished_spans
    private :set_current_span
    private :attach_sampling_priority
  end

  # ThreadLocalContext can be used as a tracer global reference to create
  # a different \Context for each thread. In synchronous tracer, this
  # is required to prevent multiple threads sharing the same \Context
  # in different executions.
  class ThreadLocalContext
    # ThreadLocalContext can be used as a tracer global reference to create
    # a different \Context for each thread. In synchronous tracer, this
    # is required to prevent multiple threads sharing the same \Context
    # in different executions.
    def initialize
      self.local = Datadog::Context.new
    end

    # Override the thread-local context with a new context.
    def local=(ctx)
      Thread.current[:datadog_context] = ctx
    end

    # Return the thread-local context.
    def local
      Thread.current[:datadog_context] ||= Datadog::Context.new
    end
  end
end
