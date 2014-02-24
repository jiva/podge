# Send a push notification to podge's master, if the master is 
# idle and 'directly addressed'.

require 'cinch'
require "net/https"

class Notify
  include Cinch::Plugin

  def initialize(*args)
    super
    @last = Time.now
  end

  listen_to :connect, method: :on_connect
  def on_connect(m)
    User(@bot.master).monitor
  end

  set :prefix, lambda { |m| Regexp.new("^" + Regexp.escape(m.bot.master + ": " )) }
  match(/.*/)
  def execute(m)
    if ((Time.now - @last) > 60) and (User(@bot.master).idle > (60 * 30))
      notify(m.user, m.message)
      @last = Time.now
    end
  end
  
  def notify(user, message)
    url = URI.parse('https://api.pushover.net/1/messages.json')
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
      token: config['pushover']['api_key'],
      user: config['pushover']['user_key'],
      title: user, 
      message: message[0,500],
      sound: 'bugle'
    })
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end
end
