require "date"
require "json"

require_relative "event"

module JSON
  def self.parse_event(input_line)
    input = JSON.parse(input_line)

    type = input["type"]
    value = input["value"]
    timestamp = Time.parse(input["timestamp"])
    tags = Hash[input["tags"].split(",").map { |tag| tag.split(":") }]

    Event.new(type, value, timestamp, tags)
  end
end

class AggregateSet
  def to_json
    aggregates = aggs.map do |aggregate|
      {
        name: aggregate.name,
        min: aggregate.min,
        max: aggregate.max,
        mean: aggregate.mean,
        median: aggregate.median,
      }
    end

    {
      aggs: aggregates,
      period_start: period_start.to_datetime.rfc3339(6),
      period_end: period_end.to_datetime.rfc3339(6),
    }.to_json
  end
end
