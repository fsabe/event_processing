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

    it "has a single aggregate" do
      expect(@aggregates_list.size).to eq 1
    end

    it "the aggregate has the event type" do
      expect(@aggregate.aggs.size).to eq 1
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

  context "with multiple events with the same type" do
    before do
      event_processor = EventProcessor.new

      event_processor.record Event.new("request_duration", 10, Time.now)
      event_processor.record Event.new("request_duration", 20, Time.now)
      event_processor.record Event.new("request_duration", 30, Time.now)
      event_processor.record Event.new("request_duration", 40, Time.now)

      @aggregates_list = event_processor.flush
      @aggregate = @aggregates_list.first
    end

    it "has a single aggregate" do
      expect(@aggregates_list.size).to eq 1
    end

    it "the aggregate has the events type" do
      expect(@aggregate.aggs.size).to eq 1
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
end
