require 'uri'

module Configerator
  @processed = []

  def required(name, method=nil, error_on_load: true)
    # Hash#fetch raises a KeyError, Hash#[] doesn't
    value = fetch_env(name, error_on_load: error_on_load)

    value = cast(value, method)

    create(name, value, error_on_load)
  end

  def optional(name, method=nil)
    value = cast(fetch_env(name), method)
    create(name, value)
  end

  def override(name, default, method=nil)
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
    orig = stringify_key(name)
    pfxd = prefix_key(name)
    meth = pfxd.downcase

    instance_variable_set(:"@#{meth}", value)

    reported_keys = has_prefix? ? "\"#{pfxd}\" or \"#{orig}\"" : "\"#{orig}\""
    instance_eval "def #{meth}; @#{meth} || (raise 'key not set: #{reported_keys}' unless #{error_on_load}) end"

    instance_eval "def #{meth}?; !!#{meth} end", __FILE__, __LINE__

    return unless has_prefix?

    @processed ||= []
    @processed << meth
  end

  def stringify_key(key)
    key.to_s.upcase
  end

  def has_prefix?
    defined?(@prefix) && !@prefix.nil? && @prefix != ""
  end

  def prefix_key(key)
    key = "#{@prefix}#{key}" if has_prefix?

    stringify_key(key)
  end

  def fetch_env(key, error_on_load: false, default: nil)
    stringified_key = stringify_key(key)

    value = if has_prefix?
              # handle two possible keys
              prefixed_key = prefix_key(key)

              ENV[prefixed_key] || ENV[stringified_key] || default
            else
              # handle one possible key
              ENV[stringified_key] || default
            end

    if value.nil? && error_on_load
      message = if has_prefix?
                  "keys not found: \"#{prefixed_key}\" or \"#{stringified_key}\""
                else
                  "key not found: \"#{stringified_key}\""
                end

        raise KeyError, message
    end

    value
  end
end
