#!/usr/bin/env ruby
# vim:set fileencoding=utf-8 ts=2 sw=2 sts=2 et:

# 使い方:
#   ./sort_range.rb {filename}
#     {filename}から整数列データを読み込み、ソートの行われていない範囲を出力します
#     なお、{filename}を省略した場合は、標準入力からデータを読み込みます
#
# 使用例:
#   ./sort_range.rb data/input_case_1.txt
#
# 速度テスト:
#   ./sort_range.rb --test {filename}
#    速度テストを行い、結果を出力します 

# 注意点
#   このプログラムはUTF-8で記述したものをShift-JISに変換しています。(解答フォーマットに合わせるため)
#   プログラムを実行する前にUTF-8に再変換して下さい。

require 'optparse'

module SortRange
  refine Array do
    public
    # unsorted_rangeの遅い実装
    def slowly_unsorted_range
      sorted_list = sort
      list_pair = zip(sorted_list).each_with_index
      (_, _), first_index = list_pair             .find{|(num, sorted_num), index| num != sorted_num}
      (_, _), last_index  = list_pair.reverse_each.find{|(num, sorted_num), index| num != sorted_num}
      return (first_index && last_index) ? (first_index .. last_index) : nil
    end
  end

  refine Array do
    public
    # この配列の未ソートの範囲を返します
    # @return [Range] 未ソートの範囲
    # @return [nil] この配列がソート済みの場合
    # @example
    #   [1, 3, 4, 7, 11, 6, 8, 9, 7, 10, 13, 14].unsorted_range # => (3..9)
    #   [1, 2, 3].unsorted_range # => nil
    def unsorted_range
      # 要素1以下ならソート済みであることは自明
      return nil if size <= 1

      first_index = calc_first_index
      return nil unless first_index

      last_index = calc_last_index
      raise unless last_index

      return (first_index .. last_index) 
    end

    private
    # @note アルゴリズムについて
    #   下記のように定義する
    #     未ソート部分の先頭のインデックス:        first
    #     インデックスxの要素の値: value(x)
    #     末尾からインデックスxまでの要素の最小値: min_value(x)
    #   このとき、firstはvalue(x) != min_value(x) となるもののうち最小のものである
    def calc_first_index
      raise if size <= 1

      min_value = at(size - 1)
      result = nil
      (size - 2).downto(0) do |i|
        current_value = at(i)
        min_value = Helper::min_of(min_value, current_value)
        result = i if current_value != min_value
      end
      return result
    end

    public

    # @note アルゴリズムはcalc_first_rangeの逆
    def calc_last_index
      raise if size <= 1

      max_value = at(0)
      result = nil
      1.upto(size - 1) do |i|
        current_value = at(i)
        max_value = Helper::max_of(max_value, current_value)
        result = i if current_value != max_value
      end
      return result
    end
  end

  # usingする側から呼び出されたくないメソッド群を定義
  class Helper
    class << self
      # @note Array#minよりも高速な実装
      def min_of(a, b)
        return a < b ? a : b
      end

      # @note Array#maxよりも高速な実装
      def max_of(a, b)
        return a > b ? a : b
      end
    end
  end
end


# includeすることで、速度計測用メソッドtlogが追加される
module TimeLogger
  class << self
    def instance
      return Thread.current[:"Mtk:Util::TimeLogger::KEY_INSANCE"] ||= Logger.new
    end
    def log(*args)
      instance.log(*args)
    end

    class Logger
      def initialize
        @previous_time = Time.now
      end
      def log(text = '')
        current_time = Time.now
        sec = current_time - @previous_time
        puts "#{text}: #{format(sec)}"
        @previous_time = current_time
      end
      def format(total_sec)
        v = total_sec
        v, sec = v.divmod(60)
        hour, min = v.divmod(60)

        return "%f sec  (%d:%02d:%02d)" % [total_sec, hour, min, sec]

      end
    end
  end

  def tlog(*args)
    TimeLogger.log(*args)
  end
end

# 標準入出力とのやりとりを定義
module Interaction
  class << self
    using SortRange
    include TimeLogger

    public
    def main
      opts = {}
      parser = OptionParser.new
      parser.on('--test', 'run test-mode'){|v| opts[:do_test] = true}
      parser.parse!(ARGV)

      if opts[:do_test]
        run_test
      else
        run_normal
      end
    end


    private
    # テストモードでの実行
    def run_test
      puts '[speed test] -----------------------'
      tlog('run program       ')

      list = read_list(ARGF)
      tlog('load file         ')

      range = list.unsorted_range
      tlog('calc by faster way')

      range2 = list.slowly_unsorted_range
      tlog('calc by slower way')

      puts
      puts '[result test] -----------------------'
      puts "faster: #{description_for_range(range)}"
      puts "slower: #{description_for_range(range2)}"
      puts (range == range2 ? 'OK' : '**NG**')
    end

    # 通常の実行
    def run_normal
      list = read_list(ARGF)
      write_answer(list.unsorted_range)
    end

    # 改行区切りの整数データを整数の配列にして返します
    # @param [IO] io 
    # @return [Arran<Integer>]
    # @raise [RuntimeError] 入力データが不正なとき
    def read_list(io)
      lines = io.readlines.map(&:chomp).reject(&:empty?)
      if lines.any?{|line| line !~ /^\d+$/}
        raise RuntimeError, 'This program accept only decimal numbers.'
      end
      list = lines.map(&:to_i).freeze
    end

    # ソート範囲を解答の形式に整形して出力します
    # @param [Range] range ソート範囲
    # @return [void]
    # @example
    #   write_answer(0..9) # "1..10" を出力
    #   write_answer(nil)  # "0"     を出力
    def write_answer(range)
      puts description_for_range(range)
    end

    def description_for_range(range)
      if range
        # Range#first および Range.last は<0から始まる数>で定義されているため、
        # 解答用の表現である<1から始まる数>に変換して出力する
        return "#{range.first + 1}..#{range.last + 1}"
      else
        return '0'
      end
    end

  end
end

if $0 == __FILE__
  Interaction::main
end

