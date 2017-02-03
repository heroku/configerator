require 'uri'
require 'minitest/autorun'
require './lib/configerator'

module Config
  extend Configerator
end

class TestConfigerator < Minitest::Test
  FIXTURES = {
    test_required: 'required',
    test_optional: 'optional',
    test_override: 'override',

    test_int: 99,
    test_float: 99.9,
    test_string: 'ninty nine',
    test_symbol: :ninty_nine,
    test_url: 'https://99.com',
    test_array_int: [ 9, 9 ],
    test_array: [ 'nine', 'nine' ],

    test_namespace1: 'namespace1',
    test_namespace2: 'namespace2',

    namespace10: 'namespace10',
    namespace11: 'namespace11'
  }.freeze

  def setup
    FIXTURES.each { |k, v|
      ENV[k.to_s.upcase] = (v.is_a?(Array) ? v.join(',') : v.to_s)
    }
  end

  def with_method
    -> (v) { "method:#{v}" }
  end

  def test_required
    Config.required :test_required

    assert_equal Config.test_required, 'required'
    assert Config.test_required?
  end

  def test_required_on_load_false
    Config.required :test_required2, error_on_load: false

    assert_raises RuntimeError do
      Config.test_required2?
    end

    assert_raises RuntimeError do
      Config.test_required2
    end
  end

  def test_required_with_method
    Config.required :test_required, with_method

    assert_equal Config.test_required, 'method:required'
    assert Config.test_required?
  end

  def test_required_missing
    assert_raises KeyError do
      Config.required :test_missing
    end
  end

  def test_optional
    Config.optional :test_optional

    assert_equal Config.test_optional, 'optional'
  end

  def test_optional_with_method
    Config.optional :test_optional, with_method

    assert_equal Config.test_optional, 'method:optional'
  end

  def test_optional_missing
    Config.optional :test_missing_optional

    assert_nil Config.test_missing_optional
  end

  def test_namespace
    Config.namespace :test do
      Config.required :namespace1
      Config.optional :namespace2
      Config.override :namespace3, "three"

      Config.required :namespace10
      Config.optional :namespace11
    end

    assert Config.test_namespace1
    assert Config.test_namespace2
    assert Config.test_namespace3
    assert Config.test_namespace10
    assert Config.test_namespace11
    assert Config.test?
  end

  def test_namepsace_missing
    Config.namespace :test do
      Config.required :namespace1
      Config.optional :namespace2
      Config.override :namespace3, "three"
      Config.optional :namespace4
    end

    assert Config.test_namespace1
    assert Config.test_namespace2
    assert Config.test_namespace3
    refute Config.test_namespace4
    refute Config.test?
  end

  def test_override
    Config.override :test_override, 'override_default'

    assert_equal Config.test_override, 'override'
  end

  def test_override_with_method
    Config.override :test_override, 'override_default', with_method

    assert_equal Config.test_override, 'method:override'
  end

  def test_override_missing
    Config.override :test_override_missing, 'override_default'

    assert_equal Config.test_override_missing, 'override_default'
  end

  # build basic casting tests
  FIXTURES.each do |meth, val|
    caster = meth.to_s.gsub(/^test_/, '')

    unless %w[required optional override url].include?(caster) || caster.start_with?("namespace")
      method = \
        if caster =~ /_/
          parts = caster.split('_')
          Config.send(parts.first.to_sym, Config.send(parts.last.to_sym))
        else
          Config.send(caster.to_sym)
        end

      define_method(meth) do
        Config.required meth, method

        assert_equal Config.send(meth), val
      end
    end
  end

  def test_url
    Config.required :test_url, Config.url

    assert_equal Config.test_url, URI.parse('https://99.com')
  end
end
