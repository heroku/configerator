require 'uri'

module Configerator
  @processed = []

  def required(name, method=nil, error_on_load: true)
    # Hash#fetch raises a KeyError, Hash#[] doesn't
    #value = error_on_load ? ENV.fetch(prefixize_key(name)) : ENV[prefixize_key(name)]
    value = fetch_env(name, error_on_load: error_on_load)

    value = cast(value, method)

    create(name, value, error_on_load)
  end

  def optional(name, method=nil)
    #value = cast(ENV[prefixize_key(name)], method)
    value = cast(fetch_env(name), method)
    create(name, value)
  end

  def override(name, default, method=nil)
    #value = cast(ENV.fetch(prefixize_key(name), default), method)
    value = cast(fetch_env(name, default: default), method)
    create(name, value)
  end

  def namespace namespace, prefix: true, &block
    @processed = []
    @prefix = "#{namespace}_" if prefix
    yield
    instance_eval "def #{namespace}?; !!(#{@processed.join(' && ')}) end"
  ensure
    @prefix = nil
    @processed = []
  end

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

  private

  def cast(value, method)
    method ? method.call(value) : value
  end

  def create(name, value, error_on_load=true)
    name = "#{@prefix}#{name}"

    instance_variable_set(:"@#{name}", value)
    instance_eval "def #{name}; @#{name} || (raise \"key not set '#{name}'\" unless #{error_on_load}) end"
    instance_eval "def #{name}?; !!#{name} end", __FILE__, __LINE__

    return unless has_prefix?

    @processed ||= []
    @processed << name
  end

  def stringify_key(key)
    key.to_s.upcase
  end

  def has_prefix?
    defined?(@prefix) && !@prefix.nil? && @prefix != ""
  end

  def prefixize_key(key)
    key = "#{@prefix}#{key}" if has_prefix?

    stringify_key(key)
  end

  def fetch_env(key, error_on_load: false, default: nil)
    stringified_key = stringify_key(key)

    value = if has_prefix?
              # handle two possible keys
              prefixed_key = prefixize_key(key)

              ENV[prefixed_key] || ENV[stringified_key] || default
            else
              # handle one possible keys
              ENV[stringified_key] || default
            end

    if value.nil? && error_on_load
      raise KeyError, "keys not found: \"#{prefixed_key}\" or \"#{stringified_key}\""
    end

    value
  end
end
