require_relative "event"
require_relative "event_processor"
require_relative "json"

class CLI
  def initialize
    @event_processor = EventProcessor.new
  end

  def record_events(input)
    input.each_line do |line|
      event = JSON.parse_event(line)
      @event_processor.record(event)
    end
  end

  def output_aggregates
    puts @event_processor.flush.map(&:to_json)
  end
end
