require_relative '../lib/configerator'

module Config
  extend Configerator

  override :name,     'Josh'
  override :color, 'purple'
end

class MyApp
  def initalize
  end

  def run
    puts "Hello %s, I hear you like the color %s!" % [
      Config.name,
      Config.color
    ]
  end
end

app = MyApp.new
app.run
