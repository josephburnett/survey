#!/usr/bin/env ruby

# Clear all cached data to fix serialization format
puts "Clearing all cached metric series and alert status data..."

# This can be run with: bin/rails runner clear_cache.rb

MetricSeriesCache.delete_all
AlertStatusCache.delete_all

puts "Cache cleared successfully!"
