module SimpleStats
  def self.pretty_stats(arr, name)
    "#{ name }: avg=#{ round_float(calc_avg(arr)) }, stdev = #{ round_float(calc_stdev(arr)) }"
  end

  def self.calc_avg(arr)
    arr.inject { |sum, elem| sum + elem }*1.0/arr.length
  end

  def self.calc_stdev(arr)
    avg = calc_avg(arr)
    variance = calc_avg(arr.collect { |i| i - avg }.collect { |i| i*i })
    Math.sqrt(variance)
  end

  def self.round_float(float)
    sprintf('%.2f', float)
  end
end