# A Redis backed scoreboard that tallies user quit events and displays the
# nicks with the most quits.

require 'redis'

class Shameboard
  include Cinch::Plugin

  def initialize(*args)
    super
    @redis = Redis.new
  end

  listen_to :quit

  def listen(m)
    @redis.zincrby('irc.scoreboard', 1, m.user.nick)
  end

  match 'shameboard' 
  def execute(m)
    scores = @redis.zrevrange('irc.scoreboard', 0, 2, with_scores: true)
    if scores.size > 0
      width = scores.transpose.first.max.size + 4
      scores.each_with_index do |elem, index|
        nick, score = elem
        m.reply("%2d   %-*s %6d" % [index + 1, width, nick, score])
      end
    else
      m.reply("empty")
    end
  end
end
