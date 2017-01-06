require_relative "aggregate"
require_relative "aggregate_set"
require_relative "event"

class EventProcessor
  attr_reader :last_flush

  # Initializes the EventProcessor to aggregate events every +interval+ seconds from the +start+ time.
  def initialize(start=Time.parse("2017-01-01T00:00:00Z"), interval=60)
    @events = []
    @start = start
    @interval = interval
  end

  # Records an event.
  def record(event)
    @events << event
  end

  # Aggregate all events recorded since the last flush and return an AggregateSet for each period that has at least one recorded event.
  def flush
    aggregate_sets = aggregate_events_by_period(@events)

    @events = []

    aggregate_sets
  end

  private

  def aggregate_events_by_period(events)
    events_by_period = events.group_by { |event| ((event.timestamp - @start) / @interval).to_i }

    events_by_period.map do |period_index, events|
      aggregates = events
        .group_by(&:type)
        .map { |type, events| Aggregate.new(type, events.map(&:value)) }

      period_start = @start + @interval * period_index
      period_end = @start + @interval * (period_index + 1)

      AggregateSet.new(aggregates, period_start, period_end)
    end
  end
end
