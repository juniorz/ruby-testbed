#!/usr/bin/env ruby

# Based on http://en.wikipedia.org/wiki/Leibniz_formula_for_pi
require 'bigdecimal'

class LeibnizPiApproximation
  class << self
    def term(n)
      BigDecimal.new(-1) ** n / (2 * n + 1)
    end

    def sum(from, to)
      (from..to).reduce(BigDecimal.new(0)){|sum, n| sum + term(n) }
    end

    # BigDecimal.new(4) * sum(0, size)
    def calculate(size = 10_000_000, num_workers = 1)
      workload = size / num_workers

      workers = num_workers.times.collect do |i|
        start = i * workload
        ending = (i + 1) * workload - 1

        Thread.new { Thread.current[:output] = sum(start, ending) }
      end

      values = workers.map(&:join).map{|t| t[:output] }

      BigDecimal.new(4) * values.reduce(BigDecimal.new(0), :+)
    end
  end
end

require 'benchmark'

Benchmark.bmbm do |bm|
  [1000, 2000, 5000, 10_000, 20_000, 30_000, 40_000, 50_000, 100_000].each do |n|
    bm.report("linear: #{n}") { LeibnizPiApproximation.calculate(n) }
    bm.report("parallel: #{n}") { LeibnizPiApproximation.calculate(n, 2) }
  end
end
