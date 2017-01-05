require "event_processor"

describe EventProcessor, "#aggregate" do
  it "is empty if no metrics were recorded" do
    event_processor = EventProcessor.new
    expect(event_processor.flush).to be_empty
  end

  context "with a single event" do
    before do
      event = Event.new("request_duration", 10, Time.now)

      event_processor = EventProcessor.new
      event_processor.record event

      @aggregates_list = event_processor.flush
      @aggregate = @aggregates_list.first
    end

    it "has a single aggregate set" do
      expect(@aggregates_list.size).to eq 1
    end

    it "the aggregate set has a single aggregate" do
      expect(@aggregate.aggs.size).to eq 1
    end

    it "the aggregate has the event type" do
      expect(@aggregate.aggs.first.name).to eq "request_duration"
    end

    it "the aggregate min value is the event value" do
      expect(@aggregate.aggs.first.min).to eq 10
    end

    it "the aggregate max value is the event value" do
      expect(@aggregate.aggs.first.max).to eq 10
    end

    it "the aggregate mean value is the event value" do
      expect(@aggregate.aggs.first.mean).to eq 10
    end

    it "the aggregate median value is the event value" do
      expect(@aggregate.aggs.first.median).to eq 10
    end
  end

  context "with multiple events with the same type in the same period" do
    before do
      event_processor = EventProcessor.new

      event_processor.record Event.new("request_duration", 10, Time.parse("2017-01-03T15:53:01.494821Z"))
      event_processor.record Event.new("request_duration", 20, Time.parse("2017-01-03T15:53:05.494122Z"))
      event_processor.record Event.new("request_duration", 30, Time.parse("2017-01-03T15:53:17.494145Z"))
      event_processor.record Event.new("request_duration", 40, Time.parse("2017-01-03T15:53:42.000000Z"))

      @aggregates_list = event_processor.flush
      @aggregate = @aggregates_list.first
    end

    it "has a single aggregate set" do
      expect(@aggregates_list.size).to eq 1
    end

    it "the aggregate set has a single aggregate" do
      expect(@aggregate.aggs.size).to eq 1
    end

    it "the aggregate has the events type" do
      expect(@aggregate.aggs.first.name).to eq "request_duration"
    end

    it "the aggregate min value is the min event value" do
      expect(@aggregate.aggs.first.min).to eq 10
    end

    it "the aggregate max value is the max event value" do
      expect(@aggregate.aggs.first.max).to eq 40
    end

    it "the aggregate mean value is the mean event value" do
      expect(@aggregate.aggs.first.mean).to eq 25
    end

    it "the aggregate median value is the median event value" do
      expect(@aggregate.aggs.first.median).to eq 25
    end
  end

  context "with multiple events with different types in the same period" do
    before do
      event_processor = EventProcessor.new

      event_processor.record Event.new("request_duration", 10, Time.parse("2017-01-03T15:53:01.494821Z"))
      event_processor.record Event.new("request_duration", 20, Time.parse("2017-01-03T15:53:05.494122Z"))
      event_processor.record Event.new("request_count", 30, Time.parse("2017-01-03T15:53:17.494145Z"))
      event_processor.record Event.new("request_count", 40, Time.parse("2017-01-03T15:53:42.000000Z"))

      @aggregates_list = event_processor.flush
      @aggregate = @aggregates_list.first
    end

    it "has a single aggregate set" do
      expect(@aggregates_list.size).to eq 1
    end

    it "the aggregate set has one aggregate for each event type" do
      expect(@aggregate.aggs.size).to eq 2

      aggregate_names = @aggregate.aggs.map(&:name)
      expect(aggregate_names).to include "request_duration"
      expect(aggregate_names).to include "request_count"
    end

    it "the aggregate min value is the min event value for that type" do
      expect(@aggregate.aggs.find { |a| a.name == "request_duration" }.min).to eq 10
      expect(@aggregate.aggs.find { |a| a.name == "request_count" }.min).to eq 30
    end

    it "the aggregate max value is the max event value for that type" do
      expect(@aggregate.aggs.find { |a| a.name == "request_duration" }.max).to eq 20
      expect(@aggregate.aggs.find { |a| a.name == "request_count" }.max).to eq 40
    end

    it "the aggregate mean value is the mean event value for that type" do
      expect(@aggregate.aggs.find { |a| a.name == "request_duration" }.mean).to eq 15
      expect(@aggregate.aggs.find { |a| a.name == "request_count" }.mean).to eq 35
    end

    it "the aggregate median value is the median event value for that type" do
      expect(@aggregate.aggs.find { |a| a.name == "request_duration" }.median).to eq 15
      expect(@aggregate.aggs.find { |a| a.name == "request_count" }.median).to eq 35
    end
  end

  context "with multiple events with the same type in different periods" do
    before do
      event_processor = EventProcessor.new

      event_processor.record Event.new("request_duration", 10, Time.parse("2017-01-03T15:53:01.494821Z"))
      event_processor.record Event.new("request_duration", 20, Time.parse("2017-01-03T15:53:05.494122Z"))

      event_processor.record Event.new("request_duration", 30, Time.parse("2017-01-03T15:54:17.494145Z"))
      event_processor.record Event.new("request_duration", 40, Time.parse("2017-01-03T15:54:42.000000Z"))

      @aggregates_list = event_processor.flush
      @first_aggregate_set, @second_aggregate_set = @aggregates_list
    end

    it "has an aggregate set for each period" do
      expect(@aggregates_list.size).to eq 2
    end

    it "each aggregate set corresponds to a period" do
      expect(@first_aggregate_set.period_start).to eq Time.parse("2017-01-03T15:53:00.000000Z")
      expect(@first_aggregate_set.period_end).to eq Time.parse("2017-01-03T15:54:00.000000Z")

      expect(@second_aggregate_set.period_start).to eq Time.parse("2017-01-03T15:54:00.000000Z")
      expect(@second_aggregate_set.period_end).to eq Time.parse("2017-01-03T15:55:00.000000Z")
    end

    it "each aggregate set has a single aggregate" do
      expect(@first_aggregate_set.aggs.size).to eq 1
      expect(@second_aggregate_set.aggs.size).to eq 1
    end

    it "the aggregate min value is the min event value for that period" do
      expect(@first_aggregate_set.aggs.first.min).to eq 10
      expect(@second_aggregate_set.aggs.first.min).to eq 30
    end

    it "the aggregate max value is the max event value for that period" do
      expect(@first_aggregate_set.aggs.first.max).to eq 20
      expect(@second_aggregate_set.aggs.first.max).to eq 40
    end

    it "the aggregate mean value is the mean event value for that period" do
      expect(@first_aggregate_set.aggs.first.mean).to eq 15
      expect(@second_aggregate_set.aggs.first.mean).to eq 35
    end

    it "the aggregate median value is the median event value for that period" do
      expect(@first_aggregate_set.aggs.first.median).to eq 15
      expect(@second_aggregate_set.aggs.first.median).to eq 35
    end
  end
end
