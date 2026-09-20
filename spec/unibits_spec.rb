require_relative "../lib/unibits/kernel_method"
require "minitest/autorun"

describe Unibits do
  it "will not work for unsupported encodings" do
    _(proc{
      Unibits.of("string".encode("UTF-32"))
    }).must_raise ArgumentError
  end

  describe 'Encodings' do
    let(:string){ "🌫 Idio﻿syncrätic ℜսᖯʏ" }

    it "works with UTF-8" do
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).must_match "ℜ"
      _(result).must_match "U+211C"
      _(result).must_match /E2.*84.*9C/m
      _(result).must_match /11100010.*10000100.*10011100/m
    end

    it "works with UTF-16LE" do
      result = Paint.unpaint(Unibits.visualize(string.encode('UTF-16LE')))
      _(result).must_match "ℜ"
      _(result).must_match "U+211C"
      _(result).must_match /1C.*21/m
      _(result).must_match /00011100.*00100001/m
    end

    it "works with UTF-16BE" do
      result = Paint.unpaint(Unibits.visualize(string.encode('UTF-16BE')))
      _(result).must_match "ℜ"
      _(result).must_match "U+211C"
      _(result).must_match /21.*1C/m
      _(result).must_match /00100001.*00011100/m
    end

    it "works with UTF-32LE" do
      result = Paint.unpaint(Unibits.visualize(string.encode('UTF-32LE')))
      _(result).must_match "ℜ"
      _(result).must_match "U+211C"
      _(result).must_match /1C.*21.*00.*00/m
      _(result).must_match /00011100.*00100001.*00000000.*00000000/m
    end

    it "works with UTF-32BE" do
      result = Paint.unpaint(Unibits.visualize(string.encode('UTF-32BE')))
      _(result).must_match "ℜ"
      _(result).must_match "U+211C"
      _(result).must_match /00.*00.*21.*1C/m
      _(result).must_match /00000000.*00000000.*00100001.*00011100/m
    end

    it "works with BINARY" do
      result = Paint.unpaint(Unibits.visualize(string.dup.force_encoding('BINARY')))
      # testing for the UTF-8 encoded "ℜ"
      _(result).must_match "\\xE2"
      _(result).must_match "\\x84"
      _(result).must_match "\\x9C"
      _(result).must_match /11100010.*10000100.*10011100/m
    end

    it "works with ASCII" do
      result = Paint.unpaint(Unibits.visualize("ASCII string".dup.force_encoding('ASCII')))
      _(result).must_match "C"
      _(result).must_match "43"
      _(result).must_match "01000011"
    end

    it "works with GB1988" do
      result = Paint.unpaint(Unibits.visualize("ASCII string".dup.force_encoding('GB1988')))
      _(result).must_match "C"
      _(result).must_match "43"
      _(result).must_match "01000011"
    end

    it "works with 'ISO-8859-X' encodings" do
      string = "\xBC Idiosyncr\xE4tic\n\x91".dup.force_encoding("ISO-8859-1")
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).must_match "BC"  # ¼
      _(result).must_match "E4"  # ä
      _(result).must_match "␊"   # \n
      _(result).must_match "PU1" # C1 name for \x91
    end

    it "works with 'Windows-125X' encodings" do
      string = "\xBC Idiosyncr\xE4tic\n\x81".dup.force_encoding("Windows-1252")
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).must_match "BC"  # ¼
      _(result).must_match "E4"  # ä
      _(result).must_match "␊"   # \n
      _(result).must_match "n/a" # \x81 is not assigned
    end

    it "works with 'IBMX' encodings" do
      string = "\xFE Idiosyncr\x84tic\n".dup.force_encoding("IBM437")
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).must_match "FE"  # ■
      _(result).must_match "84"  # ä
      _(result).must_match "␊"   # \n
    end

    it "works with 'CP85X' encodings" do
      string = "\xFE Idiosyncr\x84tic\n".dup.force_encoding("CP850")
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).must_match "FE"  # ■
      _(result).must_match "84"  # ä
      _(result).must_match "␊"   # \n
    end

    it "works with 'macX' encodings" do
      string = "\xBD Idiosyncr\x8Atic \x11 \xF0\n".dup.force_encoding("macRoman")
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).must_match "BD"   # Ω
      _(result).must_match "8A"   # ä
      _(result).must_match "Logo" # \xF0
      _(result).must_match "⌘"    # \x11
      _(result).must_match "␊"    # \n
    end

    it "works with 'TIS-620/Windows-874' encodings" do
      string = "\xA4 Idiosyncratic\n".dup.force_encoding("TIS-620")
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).must_match "A4"  # ค
      _(result).must_match "␊"   # \n
    end

    it "works with 'KOI8-X' encodings" do
      string = "\xE9\xE4\xE9\xEF\xF3\xF9\xEE\xE3\xF2\xE1\xF4\xE9\xE3\n".dup.force_encoding("KOI8-R")
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).must_match "F9"  # Ы
      _(result).must_match "␊"   # \n
    end

    describe "invalid UTF-8 encodings" do
      it "- unexpected continuation byte (1/2)" do
        string = "abc\x80efg"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "unexp.c."
        _(result).must_match /e.*f.*g/m
      end

      it "- unexpected continuation byte (2/2)" do
        string = "🌫\x81efg"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "unexp.c."
        _(result).must_match /e.*f.*g/m
      end

      it "- not enough continuation bytes" do
        string = "\xF0\x9F\x8CABC"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "n.e.con."
        _(result).must_match /A.*B.*C/m
      end

      it "- overlong padding (1/2)" do
        string = "\xE0\x81\x81ABC"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match /overlong.*overlong.*overlong/m
        _(result).must_match /A.*B.*C/m
      end

      it "- overlong padding (2/2)" do
        string = "\xC0\x80no double null"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match /overlong.*overlong/m
      end

      it "- too large codepoint (1/2)" do
        string = "\xF5\x8F\xBF\xBFABC"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match /toolarge.*toolarge.*toolarge.*toolarge/m
        _(result).must_match /A.*B.*C/m
      end

      it "- too large codepoint (2/2)" do
        string = "\xF4\xAF\xBF\xBFABC"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match /toolarge.*toolarge.*toolarge.*toolarge/m
        _(result).must_match /A.*B.*C/m
      end

      it "- too large byte" do
        string = "\xFF"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "toolarge"
      end

      it "- has surrogate (1/2)" do
        string = "\xED\xA0\x80ABC"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "sur.gate"
        _(result).must_match /A.*B.*C/m
      end

      it "- has surrogate (2/2)" do
        string = "\xED\xBF\xBFABC"
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "sur.gate"
        _(result).must_match /A.*B.*C/m
      end
    end

    describe "invalid UTF-16 encodings" do
      unless RUBY_ENGINE === "truffleruby"
        it "- incomplete number of bytes (1/2)" do
          string = "a".b.force_encoding("UTF-16LE")
          result = Paint.unpaint(Unibits.visualize(string))
          _(result).must_match "incompl."
          _(result).must_match "�"
        end

        it "- incomplete number of bytes (2/2)" do
          string = "🌫".b[0..-2].dup.force_encoding("UTF-16LE")
          result = Paint.unpaint(Unibits.visualize(string))
          _(result).must_match "incompl."
          _(result).must_match "�"
        end
      end
      it "- only lower half surrogate" do
        string = "\x3C\xD8\x2Ba".dup.force_encoding("UTF-16LE")
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "hlf.srg."
        _(result).must_match "�"
      end

      it "- only higher half surrogate" do
        string = "\x3Ca\x2B\xDF".dup.force_encoding("UTF-16LE")
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "hlf.srg."
        _(result).must_match "�"
      end
    end

    describe "invalid UTF-32 encodings" do
      # please note, currently, too large codepoints and encoded utf16 surrogates are treated as valid encodings

      unless RUBY_ENGINE === "truffleruby"
        it "- incomplete number of bytes (1/3)" do
          string = "a".b.force_encoding("UTF-32LE")
          result = Paint.unpaint(Unibits.visualize(string))
          _(result).must_match "incompl."
          _(result).must_match "�"
        end

        it "- incomplete number of bytes (2/3)" do
          string = "🌫".b[0..-2].force_encoding("UTF-32LE")
          result = Paint.unpaint(Unibits.visualize(string))
          _(result).must_match "incompl."
          _(result).must_match "�"
        end

        it "- incomplete number of bytes (3/3)" do
          string = "🌫".b[0..-2].force_encoding("UTF-32LE")
          result = Paint.unpaint(Unibits.visualize(string))
          _(result).must_match "incompl."
          _(result).must_match "�"
        end
      end

      it "- too large codepoint (1/2)" do
        string = "\x00\x00\x11\x00".dup.force_encoding("UTF-32LE")
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "toolarge"
      end

      it "- too large codepoint (2/2)" do
        string = "\x00\x00\x00\x01".dup.force_encoding("UTF-32LE")
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "toolarge"
      end

      it "- has surrogate" do
        string = "\x00\xD8\x00\x00".dup.force_encoding("UTF-32LE")
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match "sur.gate"
      end
    end

    describe "invalid ASCII encodings" do
      it "- contains bytes with 8th bit set" do
        string = "abc\x80efg".dup.force_encoding("ASCII")
        result = Paint.unpaint(Unibits.visualize(string))
        _(result).must_match "�"
        _(result).must_match /e.*f.*g/m
      end
    end
  end

  describe "wide_ambiguous: option" do
    it "- default is 1" do
      string = "⚀······"
      result = Unibits.stats(string)
      _(result).wont_match "13"
    end

    it "- default is 2" do
      string = "⚀······"
      result = Unibits.stats(string, wide_ambiguous: true)
      _(result).must_match "13"
    end
  end

  describe "width: option" do
    it "sets a custom column width" do
      string = "bla" * 99
      result = Paint.unpaint(Unibits.visualize(string, width: 50))
      _((result[/^.*$/].size <= 50)).must_equal true
    end
  end

  describe "bugs / edge cases" do
    it "should render ASCII space (U+20) as one byte [gh #1]" do
      string = "\u{1f32b} abc"
      result = Paint.unpaint(Unibits.visualize(string))
      _(result).wont_match /20.*20.*5B/m
      _(result).must_match /F0.*9F.*8C.*AB.*20.*61.*62.*63/m
    end
  end
end
