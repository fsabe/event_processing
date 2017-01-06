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
    events_by_period = @events.group_by { |event| ((event.timestamp - @start) / @interval).to_i }

    aggregate_sets = []

    events_by_period.each_pair do |period, events|
      aggregates_list = []

      events
        .group_by { |event| event.type }
        .each_pair { |type, events|
          aggregates_list << Aggregate.new(type, events.map(&:value))
        }

      period_start = @start + @interval * period
      period_end = @start + @interval * (period + 1)

      aggregate_sets << AggregateSet.new(aggregates_list, period_start, period_end)
    end

    @events = []

    aggregate_sets
  end
end
