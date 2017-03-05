require_relative "../lib/unicolors/kernel_method"
require "minitest/autorun"

describe Unicolors do
  it "will not work for unsupported encodings" do
    proc{
      Unicolors.of("string".encode("UTF-32"))
    }.must_raise ArgumentError
  end

  describe 'Encodings' do
    let(:string){ "🌫 Idio﻿syncrätic ℜսᖯʏ" }

    it "works with UTF-8" do
      result = Paint.unpaint(Unicolors.visualize(string))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /E2.*84.*9C/m
      result.must_match /11100010.*10000100.*10011100/m
    end

    it "works with UTF-16LE" do
      result = Paint.unpaint(Unicolors.visualize(string.encode('UTF-16LE')))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /1C.*21/m
      result.must_match /00011100.*00100001/m
    end

    it "works with UTF-16BE" do
      result = Paint.unpaint(Unicolors.visualize(string.encode('UTF-16BE')))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /21.*1C/m
      result.must_match /00100001.*00011100/m
    end

    it "works with UTF-32LE" do
      result = Paint.unpaint(Unicolors.visualize(string.encode('UTF-32LE')))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /1C.*21.*00.*00/m
      result.must_match /00011100.*00100001.*00000000.*00000000/m
    end

    it "works with UTF-32BE" do
      result = Paint.unpaint(Unicolors.visualize(string.encode('UTF-32BE')))
      result.must_match "ℜ"
      result.must_match "U+211C"
      result.must_match /00.*00.*21.*1C/m
      result.must_match /00000000.*00000000.*00100001.*00011100/m
    end

    it "works with BINARY" do
      result = Paint.unpaint(Unicolors.visualize(string.dup.force_encoding('BINARY')))
      # testing for the UTF-8 encoded "ℜ"
      result.must_match "\\xE2"
      result.must_match "\\x84"
      result.must_match "\\x9C"
      result.must_match /11100010.*10000100.*10011100/m
    end

    it "works with ASCII" do
      result = Paint.unpaint(Unicolors.visualize("ASCII string".force_encoding('ASCII')))
      result.must_match "C"
      result.must_match "43"
      result.must_match "01000011"
    end
  end
end
