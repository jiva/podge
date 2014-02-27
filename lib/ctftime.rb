
require 'rss'
require 'open-uri'
require 'sanitize'
require 'string-irc'

class CTFTime
  include Cinch::Plugin

  match 'ctfs'
  def execute(m)
    url = 'https://ctftime.org/event/list/upcoming/rss/'

    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.first(3).each do |item|
        if item.description
          description = sanitize_and_colorize(item)
          description.each_line do |line|
            m.reply(line)
          end
          m.reply('  ')
        end
      end
    end
  end

  def sanitize_and_colorize(item)
    description = Sanitize.clean(item.description)
    description.gsub!('[add to calendar]', '')

    title = StringIrc.new(item.title).green.bold.to_s
    description.gsub!(item.title, title)

    dates = description[/Date: (.*)/, 1]
    description.gsub!(dates, StringIrc.new(dates).yellow.bold.to_s)

    format = description[/Format: (.*)/, 1]
    description.gsub!(format, StringIrc.new(format).blue.bold.to_s)
    
    description
  end
end
