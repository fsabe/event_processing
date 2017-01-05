require "aggregate"
require "aggregate_set"
require "event"

class EventProcessor
  def initialize
    @events = []
  end

  def record(event)
    @events << event
  end

  def flush
    # ignores the timestamp for the time being
    return [] if @events.empty?

    aggregates_list = []

    @events
      .group_by { |event| event.type }
      .each_pair { |type, events|
        aggregates_list << Aggregate.new(type, events.map(&:value))
      }

    [ AggregateSet.new(aggregates_list, nil, nil) ]
  end
end
