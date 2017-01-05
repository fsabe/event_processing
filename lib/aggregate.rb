require "facets/math/mean"
require "facets/math/median"

class Aggregate
  attr_reader :name, :min, :max, :mean, :median

  def initialize(name, values)
    @name = name
    @min = values.min
    @max = values.max
    @mean = Math.mean(values)
    @median = Math.median(values)
  end
end
