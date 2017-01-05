class AggregateSet
  attr_reader :aggs, :period_start, :period_end

  def initialize(aggs, period_start, period_end)
    @aggs = aggs
    @period_start = period_start
    @period_end = period_end
  end
end
