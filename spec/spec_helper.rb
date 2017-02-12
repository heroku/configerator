require './lib/configerator'

def stub_environment env
  env.each { |key, value| allow(ENV).to receive(:[]).with(key.to_s.upcase).and_return(value) }
end

def unstub_environment
  allow(ENV).to  receive(:[]).and_call_original
end

def with_environment env
  stub_environment(env)

  yield

  unstub_environment
end
