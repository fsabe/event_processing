class Event
  attr_reader :type, :value, :timestamp, :tags

  def initialize(type, value, timestamp, tags={})
    @type = type
    @value = value
    @timestamp = timestamp
    @tags = tags
  end
end