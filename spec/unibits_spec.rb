require_relative "../lib/unibits/kernel_method"
require "minitest/autorun"

describe Unibits do
  it "will not work for unsupported encodings" do
    proc{
      Unibits.of("string".encode("UTF-32"))
    }.must_raise ArgumentError
  end

  describe 'Encodings' do
    let(:string){ "🌫 Idio﻿syncrätic ℜսᖯʏ" }

    it "works with UTF-8" do
      result = Paint.unpaint(Unibits.visualize(string))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /E2.*84.*9C/m
      result.must_match /11100010.*10000100.*10011100/m
    end

    it "works with UTF-16LE" do
      result = Paint.unpaint(Unibits.visualize(string.encode('UTF-16LE')))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /1C.*21/m
      result.must_match /00011100.*00100001/m
    end

    it "works with UTF-16BE" do
      result = Paint.unpaint(Unibits.visualize(string.encode('UTF-16BE')))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /21.*1C/m
      result.must_match /00100001.*00011100/m
    end

    it "works with UTF-32LE" do
      result = Paint.unpaint(Unibits.visualize(string.encode('UTF-32LE')))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /1C.*21.*00.*00/m
      result.must_match /00011100.*00100001.*00000000.*00000000/m
    end

    it "works with UTF-32BE" do
      result = Paint.unpaint(Unibits.visualize(string.encode('UTF-32BE')))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /00.*00.*21.*1C/m
      result.must_match /00000000.*00000000.*00100001.*00011100/m
    end

    it "works with BINARY" do
      result = Paint.unpaint(Unibits.visualize(string.dup.force_encoding('BINARY')))
      # testing for the UTF-8 encoded "ℜ"
      result.must_match "\\xE2"
      result.must_match "\\x84"
      result.must_match "\\x9C"
      result.must_match /11100010.*10000100.*10011100/m
    end

    it "works with ASCII" do
      result = Paint.unpaint(Unibits.visualize("ASCII string".force_encoding('ASCII')))
      result.must_match "C"
      result.must_match "43"
      result.must_match "01000011"
    end

    describe "invalid UTF-8 encodings" do
      it "- unexpected continuation byte (1/2)" do
        string = "abc\x80efg"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match "unexp.c."
        result.must_match /e.*f.*g/m
      end

      it "- unexpected continuation byte (2/2)" do
        string = "🌫\x81efg"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match "unexp.c."
        result.must_match /e.*f.*g/m
      end

      it "- not enough continuation bytes" do
        string = "\xF0\x9F\x8CABC"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match "n.e.con."
        result.must_match /A.*B.*C/m
      end

      it "- overlong padding (1/2)" do
        string = "\xE0\x81\x81ABC"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match /overlong.*overlong.*overlong/m
        result.must_match /A.*B.*C/m
      end

      it "- overlong padding (2/2)" do
        string = "\xC0\x80no double null"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match /overlong.*overlong/m
      end

      it "- too large codepoint (1/2)" do
        string = "\xF5\x8F\xBF\xBFABC"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match /toolarge.*toolarge.*toolarge.*toolarge/m
        result.must_match /A.*B.*C/m
      end

      it "- too large codepoint (2/2)" do
        string = "\xF4\xAF\xBF\xBFABC"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match /toolarge.*toolarge.*toolarge.*toolarge/m
        result.must_match /A.*B.*C/m
      end

      it "- too large byte" do
        string = "\xFF"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match "toolarge"
      end

      it "- has surrogate (1/2)" do
        string = "\xED\xA0\x80ABC"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match "sur.gate"
        result.must_match /A.*B.*C/m
      end

      it "- has surrogate (2/2)" do
        string = "\xED\xBF\xBFABC"
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match "sur.gate"
        result.must_match /A.*B.*C/m
      end
    end

    describe "invalid UTF-16 encodings" do
      it "- incomplete number of bytes (1/2)" do
        string = "a".b.force_encoding("UTF-16LE")
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "incompl."
        result.must_match "�"
      end

      it "- incomplete number of bytes (2/2)" do
        string = "🌫".b[0..-2].force_encoding("UTF-16LE")
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "incompl."
        result.must_match "�"
      end

      it "- only lower half surrogate" do
        string = "\x3C\xD8\x2Ba".force_encoding("UTF-16LE")
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "hlf.srg."
        result.must_match "�"
      end

      it "- only higher half surrogate" do
        string = "\x3Ca\x2B\xDF".force_encoding("UTF-16LE")
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "hlf.srg."
        result.must_match "�"
      end
    end

    describe "invalid UTF-32 encodings" do
      # please note, currently, too large codepoints and encoded utf16 surrogates are treated as valid encodings

      it "- incomplete number of bytes (1/3)" do
        string = "a".b.force_encoding("UTF-32LE")
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "incompl."
        result.must_match "�"
      end

      it "- incomplete number of bytes (2/3)" do
        string = "🌫".b[0..-2].force_encoding("UTF-32LE")
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "incompl."
        result.must_match "�"
      end

      it "- incomplete number of bytes (3/3)" do
        string = "🌫".b[0..-2].force_encoding("UTF-32LE")
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "incompl."
        result.must_match "�"
      end
    end

    describe "invalid ASCII encodings" do
      it "- contains bytes with 8th bit set" do
        string = "abc\x80efg".force_encoding("ASCII")
        result = Paint.unpaint(Unibits.visualize(string))
        result.must_match "�"
        result.must_match /e.*f.*g/m
      end
    end
  end

  describe "wide_ambiguous: option" do
    it "- default is 1" do
      string = "⚀······"
      result = Unibits.stats(string)
      result.wont_match "13"
    end

    it "- default is 2" do
      string = "⚀······"
      result = Unibits.stats(string, wide_ambiguous: true)
      result.must_match "13"
    end
  end

  describe "width: option" do
    it "sets a custom column width" do
      string = "bla" * 99
      result = Paint.unpaint(Unibits.visualize(string, width: 50))
      (result[/^.*$/].size <= 50).must_equal true
    end
  end

  describe "bugs / edge cases" do
    it "should render ASCII space (U+20) as one byte [gh #1]" do
      string = "\u{1f32b} abc"
      result = Paint.unpaint(Unibits.visualize(string))
      result.wont_match /20.*20.*5B/m
      result.must_match /F0.*9F.*8C.*AB.*20.*61.*62.*63/m
    end
  end
end
