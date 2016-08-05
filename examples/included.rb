require_relative '../lib/configerator'

class MyApp
  include Configerator

  def initialize name, color
    override :name,  name
    override :color, color
  end

  def run
    puts "Hello %s, I hear you like the color %s!" % [ name, color ]
  end
end

app = MyApp.new('Josh', 'purple')
app.run
