require 'uri'

module Configerator
  # Initializers (DSL)
  def required(name, method=nil, error_on_load: true)
    value = cast(fetch_env(name, error_on_load: error_on_load), method)

    create(name, value, error_on_load)
  end

  def optional(name, method=nil)
    value = cast(fetch_env(name), method)
    create(name, value)
  end

  def override(name, default, method=nil)
    value = cast(fetch_env(name) || default, method)
    create(name, value)
  end

  def namespace namespace, prefix: true, &block
    @processed = []
    @prefix = "#{namespace}_" if prefix

    yield

    instance_eval "def #{namespace}?; !!(#{@processed.join(' && ')}) end", __FILE__, __LINE__
  ensure
    @prefix = nil
    @processed = []
  end

  # Scope methods
  def int
    ->(v) { v.to_i }
  end

  def float
    ->(v) { v.to_f }
  end

  def bool
    ->(v) { v.to_s=='true'}
  end

  def string
    nil
  end

  def symbol
    ->(v) { v.to_sym }
  end

  def url
    ->(v) { v && URI.parse(v) }
  end

  # optional :accronyms, array(string)
  # => ['a', 'b']
  # optional :numbers, array(int)
  # => [1, 2]
  # optional :notype, array
  # => ['a', 'b']
  def array(method = nil)
    -> (v) do
      if v
        v.split(',').map{|a| cast(a, method) }
      end
    end
  end

  # Helpers
  private

  def cast(value, method)
    method ? method.call(value) : value
  end

  def create(name, value, error_on_load=true)
    name = build_key(name).downcase

    instance_variable_set(:"@#{name}", value)

    instance_eval "def #{name}; @#{name} || (raise 'key not set: \"#{name.upcase}\"' unless #{error_on_load}) end", __FILE__, __LINE__
    instance_eval "def #{name}?; !!#{name} end", __FILE__, __LINE__

    @processed ||= []
    @processed << name
  end

  def build_key(key)
    key = "#{@prefix}#{key}" if @prefix

    key.to_s.upcase
  end

  def fetch_env(key, error_on_load: false)
    key = build_key(key)

    error_on_load ? ENV.fetch(key) : ENV[key]
  end
end
