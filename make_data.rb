# vim:set fileencoding=utf-8 ts=2 sw=2 sts=2 et:

if $0 == __FILE__
  TIMES = 100_0000
  MAX = 100_0000_0000
  TIMES.times do
    puts rand(MAX)
  end
end

