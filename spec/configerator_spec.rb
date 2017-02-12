require 'uri'
require 'spec_helper'

describe Configerator do
  let(:config) { Module.new { extend Configerator } }

  describe :required do
    it "loads required value" do
      with_environment foo: "bar" do
        config.required :foo

        expect(config.foo).to eq "bar"
        expect(config.foo?).to be true
      end
    end

    it "errors when missing required value" do
      with_environment foo: nil do
        expect { config.required :foo }.to raise_error(KeyError)
      end
    end

    it "errors when calling missing required value when error_on_load: false" do
      with_environment foo: nil do
        config.required :foo, error_on_load: false

        expect { config.foo  }.to raise_error(RuntimeError)
        expect { config.foo? }.to raise_error(RuntimeError)
      end
    end

    describe "with method" do
      let(:method) { ->(v) { "method:#{v}" } }

      it "applies method" do
        with_environment foo: "bar" do
          config.required :foo, method

          expect(config.foo).to  eq "method:bar"
        end
      end
    end
  end

  describe :optional do
    it "loads optional value" do
      with_environment foo: "bar" do
        config.optional :foo

        expect(config.foo).to  eq "bar"
        expect(config.foo?).to be true
      end
    end

    it "accepts missing value" do
      with_environment foo: nil do
        config.optional :foo

        expect(config.foo).to  be nil
        expect(config.foo?).to be false
      end
    end

    describe "with method" do
      let(:method) { ->(v) { "method:#{v}" } }

      it "applies method" do
        with_environment foo: "bar" do
          config.optional :foo, method

          expect(config.foo).to  eq "method:bar"
        end
      end
    end
  end

  describe :override do
    it "loads override value" do
      with_environment foo: "bar" do
        config.override :foo, "bah"

        expect(config.foo).to  eq "bar"
        expect(config.foo?).to be true
      end
    end

    it "uses default with missing value" do
      with_environment foo: nil do
        config.override :foo, "bah"

        expect(config.foo).to  eq "bah"
        expect(config.foo?).to be true
      end
    end

    describe "with method" do
      let(:method) { ->(v) { "method:#{v}" } }

      it "applies method when set" do
        with_environment foo: "bar" do
          config.override :foo, "bah", method

          expect(config.foo).to  eq "method:bar"
        end
      end

      it "applies method when not set" do
        with_environment foo: nil do
          config.override :foo, "bah", method

          expect(config.foo).to  eq "method:bah"
        end
      end
    end
  end

  describe :namespace do
    describe "with prefix: true" do
      let(:env) { {
        example_foo: "bar",
        example_bah: "boo",
        example_bin: nil
      } }

      before { stub_environment(env) }
      after  { unstub_environment }

      it "loads environment" do
        config.namespace :example, prefix: true do
          config.required :foo
          config.optional :bah
          config.override :bin, "baz"
        end

        expect(config.example_foo).to eq "bar"
        expect(config.example_bah).to eq "boo"
        expect(config.example_bin).to eq "baz"
        expect(config.example?).to    be true
      end

      it "namespace check fails when missing" do
        config.namespace :example, prefix: true do
          config.required :foo
          config.optional :bah
          config.optional :bin
        end

        expect(config.example?).to be false
      end
    end

    describe "with prefix: false" do
      let(:env) { {
        foo: "bar",
        bah: "boo",
        bin: nil
      } }

      before { stub_environment(env) }
      after  { unstub_environment }

      it "loads environment" do
        config.namespace :example, prefix: false do
          config.required :foo
          config.optional :bah
          config.override :bin, "baz"
        end

        expect(config.foo).to eq "bar"
        expect(config.bah).to eq "boo"
        expect(config.bin).to eq "baz"
        expect(config.example?).to    be true
      end

      it "namespace check fails when missing" do
        config.namespace :example, prefix: false do
          config.required :foo
          config.optional :bah
          config.optional :bin
        end

        expect(config.example?).to be false
      end
    end

    describe "respects required errors" do
      it "throws error on load" do
        with_environment example_foo: nil do
          expect {
            config.namespace :example do
              config.required :foo, error_on_load: true
            end
          }.to raise_error(KeyError)
        end

        with_environment foo: nil do
          expect {
            config.namespace :example, prefix: false do
              config.required :foo, error_on_load: true
            end
          }.to raise_error(KeyError)
        end
      end
    end

    describe "respects required error on call" do
      it "throws error on load" do
        with_environment example_foo: nil do
          config.namespace :example do
            config.required :foo, error_on_load: false
          end

          expect { config.example_foo }.to  raise_error(RuntimeError)
          expect { config.example_foo? }.to raise_error(RuntimeError)
          expect { config.example? }.to     raise_error(RuntimeError)
        end

        with_environment foo: nil do
          config.namespace :example, prefix: false do
            config.required :foo, error_on_load: false
          end

          expect { config.foo }.to      raise_error(RuntimeError)
          expect { config.foo? }.to     raise_error(RuntimeError)
          expect { config.example? }.to raise_error(RuntimeError)
        end
      end
    end
  end

  describe :cast do
    { int:    1,
      float:  1.1,
      bool:   true,
      string: "string",
      symbol: :symbol,
    }.each do |cast, value|
      it "casts #{cast}" do
        expect(config.send(:cast, value.to_s, config.send(cast))).to eq value
      end
    end

    it "casts url" do
      expect(config.send(:cast, "http://www.example.com", config.url)).to eq URI.parse("http://www.example.com")
    end

    it "casts array of ints" do
      expect(config.send(:cast, "1,2", config.array(config.int))).to eq [ 1, 2 ]
    end

    it "casts array of floats" do
      expect(config.send(:cast, "1.1,2.2", config.array(config.float))).to eq [ 1.1, 2.2 ]
    end

    it "casts array of bools" do
      expect(config.send(:cast, "true,false", config.array(config.bool))).to eq [ true, false ]
    end

    it "casts array of strings" do
      expect(config.send(:cast, "a,b", config.array)).to eq [ "a", "b" ]
      expect(config.send(:cast, "a,b", config.array(config.string))).to eq [ "a", "b" ]
    end

    it "casts array of symbols" do
      expect(config.send(:cast, "a,b", config.array(config.symbol))).to eq [ :a, :b ]
    end

    it "casts array of urls" do
      foo = "https://www.example.com/foo"
      bar = "https://www.example.com/bar"

      expect(config.send(:cast, [foo, bar].join(","), config.array(config.url))).to eq [ URI.parse(foo), URI.parse(bar) ]
    end
  end
end
