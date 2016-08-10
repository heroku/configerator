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

    test_group1: 'one',
    test_group2: 'two'
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
    Config.send(:required, :test_required)

    assert_equal Config.test_required, 'required'
    assert Config.test_required?
  end

  def test_required_on_load_false
    Config.send(:required, :test_required2, error_on_load: false)

    refute Config.send(:test_required2?)
    assert_raises RuntimeError do
      Config.send(:test_required2)
    end
  end

  def test_required_with_method
    Config.send(:required, :test_required, with_method)

    assert_equal Config.test_required, 'method:required'
    assert Config.test_required?
  end

  def test_required_missing
    assert_raises KeyError do
      Config.send(:required, :test_missing)
    end
  end

  def test_optional
    Config.send(:optional, :test_optional)

    assert_equal Config.test_optional, 'optional'
  end

  def test_optional_with_method
    Config.send(:optional, :test_optional, with_method)

    assert_equal Config.test_optional, 'method:optional'
  end

  def test_optional_missing
    Config.send(:optional, :test_missing_optional)

    assert_nil Config.test_missing_optional
  end

  def test_optional_grouping
    Config.send(:optional, { test_group: [ :test_group1, :test_group2 ] })

    assert Config.test_group1
    assert Config.test_group2
    assert Config.test_group?
  end

  def test_optional_grouping_missing
    Config.send(:optional, { test_group: [ :test_group1, :test_group2, :test_group3 ] })

    assert Config.test_group1
    assert Config.test_group2
    refute Config.test_group3
    refute Config.test_group?
  end

  def test_override
    Config.send(:override, :test_override, 'override_default')

    assert_equal Config.test_override, 'override'
  end

  def test_override_with_method
    Config.send(:override, :test_override, 'override_default', with_method)

    assert_equal Config.test_override, 'method:override'
  end

  def test_override_missing
    Config.send(:override, :test_override_missing, 'override_default')

    assert_equal Config.test_override_missing, 'override_default'
  end

  # build basic casting tests
  FIXTURES.each do |meth, val|
    caster = meth.to_s.gsub(/^test_/, '')

    unless %w[ required optional override url ].include? caster
      method = \
        if caster =~ /group/
          nil
        elsif caster =~ /_/
          parts = caster.split('_')
          Config.send(parts.first.to_sym, Config.send(parts.last.to_sym))
        else
          Config.send(caster.to_sym)
        end

      define_method(meth) do
        Config.send(:required, meth, method)

        assert_equal Config.send(meth), val
      end
    end
  end

  def test_url
    Config.send(:required, :test_url, Config.url)

    assert_equal Config.test_url, URI.parse('https://99.com')
  end
end
