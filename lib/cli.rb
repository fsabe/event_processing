require "date"
require "json"

require_relative "event"
require_relative "event_processor"

class CLI
  def initialize
    @event_processor = EventProcessor.new
  end

  def record_events(input)
    input.each_line do |line|
      event = parse(line)
      @event_processor.record(event)
    end
  end

  def output_aggregates
    puts @event_processor.flush.map { |aggregate_set| to_json(aggregate_set) }
  end

  private

  def parse(input_line)
    input = JSON.parse(input_line)

    type = input["type"]
    value = input["value"]
    timestamp = Time.parse(input["timestamp"])
    tags = Hash[input["tags"].split(",").map { |tag| tag.split(":") }]

    Event.new(type, value, timestamp, tags)
  end

  def to_json(aggregate_set)
    aggs = aggregate_set.aggs.map do |aggregate|
      {
        name: aggregate.name,
        min: aggregate.min,
        max: aggregate.max,
        mean: aggregate.mean,
        median: aggregate.median,
      }
    end

    {
      aggs: aggs,
      period_start: aggregate_set.period_start.to_datetime.rfc3339(6),
      period_end: aggregate_set.period_end.to_datetime.rfc3339(6),
    }.to_json
  end
end
