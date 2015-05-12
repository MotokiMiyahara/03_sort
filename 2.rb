# vim:set fileencoding=utf-8 ts=2 sw=2 sts=2 et:



if $0 == __FILE__
  1.upto(100_0000) do |i|
    n = case i
      when 1000
        1001
      when 1001
        1000
      else
        i
    end

    puts n
  end

end

