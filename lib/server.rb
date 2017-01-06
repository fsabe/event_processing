require_relative "event_processor"
require_relative "json"

class Server
  def initialize(start=Time.parse("2017-01-01T00:00:00Z"), flush_interval=120)
    @event_processor = EventProcessor.new(start)
    @flush_interval = flush_interval
    @last_flush = start
  end

  def listen(address="0.0.0.0", port=3030)
    socket = UDPSocket.new
    socket.bind(address, port)

    loop do
      message, _sender = socket.recvfrom(65536)

      message.each_line do |line|
        begin
          event = JSON.parse_event(line)
          if event.timestamp >= @last_flush + @flush_interval
            puts @event_processor.flush.map(&:to_json)
            @last_flush = event.timestamp
          end

          @event_processor.record(event)
        rescue
          # Bad message format.
        end
      end
    end
  end

  def force_flush
    aggregate_sets = @event_processor.flush

    unless aggregate_sets.empty?
      @last_flush = aggregate_sets.last.period_end
      puts aggregate_sets.map(&:to_json)
    end
  end
end
