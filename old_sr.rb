#!/usr/bin/env ruby
# vim:set fileencoding=utf-8 ts=2 sw=2 sts=2 et:

require 'pp'

class SortRangeCalculator
  def initialize(list)
    @list = list.dup.freeze
    @range = nil
    @range_calced = false
  end

  def range
    return @range if @range_calced
    return @range = calc_range
  end


  private
  def calc_range
    right_mins = calc_right_mins(@list)
    range_first = calc_range_first(right_mins)
    return nil unless range_first


    left_maxs = calc_left_maxs(@list)
    range_last = calc_range_last(left_maxs)
    raise unless range_last
    return (range_first .. range_last)
  end

  def calc_range_first(right_mins)
    range_first = nil
    left_max = - Float::INFINITY   
    @list.each_with_index do |n, index|
      unless n == right_mins[index]
        range_first = index
        break
      end
    end
    return range_first
  end

  # 下記を高速化したもの
  #  return list.each_with_index.map{|_, index| list[index..-1].min}
  def calc_right_mins(list)
    result = Array.new(list.size)
    min = Float::INFINITY   
    list.each_with_index.reverse_each do |n, index|
      #min = [n, min].min
      min = n < min ? n : min
      result[index] = min
    end
    return result.freeze
  end

  
  def calc_range_last(left_maxs)
    range_last = nil
    left_max = - Float::INFINITY   
    @list.each_with_index.reverse_each do |n, index|
      unless n == left_maxs[index]
        range_last = index
        break
      end
    end
    return range_last
  end

  # 下記を高速化したもの
  #  return list.each_with_index.map{|_, index| list[0..index].max}
  def calc_left_maxs(list)
    result = Array.new(list.size)
    max = -Float::INFINITY   
    list.each_with_index do |n, index|
      #max = [n, max].max
      max = max < n ? n : max
      result[index] = max
    end
    return result.freeze
  end

end

module Interaction
  module_function
  def read_list(argf)
    lines = argf.readlines.map(&:chomp).reject(&:empty?)
    if lines.any?{|line| line !~ /^\d+$/}
      raise RuntimeError, 'This program apply accept only decimal numbers.'
    end
    list = lines.map(&:to_i).freeze
  end

  def write_answer(range)
    if range
      puts "#{range.first + 1}..#{range.last + 1}"
    else
      puts 0
    end
  end
end

def calc_range_slowly(list)
  sorted = list.sort
  zip = list.zip(sorted).each_with_index
  (_, _), first = zip.find{|(num, sorted_num), index| num  != sorted_num}
  (_, _), last =  zip.reverse_each.find{|(num, sorted_num), index| num  != sorted_num}
  return (first && last) ? (first .. last) : nil
end

def calc_unsorted_range(list)
  sorted_list = list.sort
  list_pair = list.zip(sorted_list).each_with_index
  (_, _), first_index = list_pair             .find{|(num, sorted_num), index| num != sorted_num}
  (_, _), last_index  = list_pair.reverse_each.find{|(num, sorted_num), index| num != sorted_num}
  return (first_index && last_index) ? (first_index .. last_index) : nil
end

if $0 == __FILE__

  #include Interaction
  #list = read_list(ARGF)
  #calc = SortRangeCalculator.new(list)
  #write_answer(calc.range)

  require 'mtk/util'
  include Interaction
  tlog(0)
  list = read_list(ARGF)
  tlog(1)
  calc = SortRangeCalculator.new(list)
  write_answer(calc.range)
  tlog(2)
  write_answer(calc_unsorted_range(list))
  tlog(3)

end

