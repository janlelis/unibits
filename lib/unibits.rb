require_relative "unibits/version"

require "io/console"
require "paint"
require "unicode/display_width"

module Unibits
  SUPPORTED_ENCODINGS = [
    'UTF-8',
    'UTF-16LE',
    'UTF-16BE',
    'UTF-32LE',
    'UTF-32BE',
    'ASCII-8BIT',
    'US-ASCII',
  ].freeze

  def self.of(string, encoding: nil, convert: nil)
    if !string || string.empty?
      raise ArgumentError, "no data given to unibits"
    end

    string.force_encoding(encoding) if encoding
    string = string.encode(convert) if convert

    case string.encoding.name
    when *SUPPORTED_ENCODINGS
      puts visualize(string)
    when 'UTF-16', 'UTF-32'
      raise ArgumentError, "unibits only supports #{string.encoding.name} with specified endianess, please use #{string.encoding.name}LE or #{string.encoding.name}BE"
    else
      raise ArgumentError, "unibits does not support strings of encoding #{string.encoding}"
    end
  end

  def self.visualize(string)
    cols = determine_terminal_cols

    cp_buffer  = ["  "]
    enc_buffer = ["  "]
    hex_buffer = ["  "]
    bin_buffer = ["  "]
    separator  = ["  "]

    puts
    string.each_char{ |char|
      current_color = random_color

      char.each_byte.with_index{ |byte, index|
        if Paint.unpaint(hex_buffer[-1]).bytesize > cols - 12
          cp_buffer  << "  "
          enc_buffer << "  "
          hex_buffer << "  "
          bin_buffer << "  "
          separator  << "  "
        end

        if index == 0
          cp_buffer[-1] << Paint[
            ("U+%04X" % char.ord).ljust(10), current_color, :bold
          ]

          symbolified_char = symbolify(char)
          padding = 10 - Unicode::DisplayWidth.of(symbolified_char)

          enc_buffer[-1] << Paint[
            symbolified_char, current_color
          ]
          enc_buffer[-1] << " " * padding if padding > 0
        else
          cp_buffer[-1]  << " " * 10
          enc_buffer[-1] << " " * 10
        end

        hex_buffer[-1] << Paint[
          ("%02X" % byte).ljust(10, " "), current_color
        ]

        bin_byte_complete = byte.to_s(2).rjust(8, "0")

        case string.encoding.name
        when 'US-ASCII'
          bin_byte_1 = bin_byte_complete[0...1]
          bin_byte_2 = bin_byte_complete[1...8]
        when 'ASCII-8BIT'
          bin_byte_1 = ""
          bin_byte_2 = bin_byte_complete
        when 'UTF-8'
          if index == 0
            if bin_byte_complete =~ /^(0|1{2,4}0)([01]+)$/
              bin_byte_1 = $1
              bin_byte_2 = $2
            else
              bin_byte_1 = ""
              bin_byte_2 = bin_byte_complete
            end
          else
            bin_byte_1 = bin_byte_complete[0...2]
            bin_byte_2 = bin_byte_complete[2...8]
          end
        when 'UTF-16LE'
          if char.ord <= 0xFFFF || index == 0 || index == 2
            bin_byte_1 = ""
            bin_byte_2 = bin_byte_complete
          else
            bin_byte_complete =~ /^(11011[01])([01]+)$/
            bin_byte_1 = $1
            bin_byte_2 = $2
          end
        when 'UTF-16BE'
          if char.ord <= 0xFFFF || index == 1 || index == 3
            bin_byte_1 = ""
            bin_byte_2 = bin_byte_complete
          else
            bin_byte_complete =~ /^(11011[01])([01]+)$/
            bin_byte_1 = $1
            bin_byte_2 = $2
          end
        when 'UTF-32LE', 'UTF-32BE'
          bin_byte_1 = ""
          bin_byte_2 = bin_byte_complete
        end
        bin_buffer[-1] << Paint[
          bin_byte_1, current_color
        ] unless !bin_byte_1 || bin_byte_1.empty?
        bin_buffer[-1] << Paint[
          bin_byte_2, current_color, :underline
        ] unless !bin_byte_2 || bin_byte_2.empty?
        bin_buffer[-1] << "  "
      }
    }

    if string.encoding.name[0, 3] == "UTF"
      enc_buffer.zip(cp_buffer, hex_buffer, bin_buffer, separator).flatten.join("\n")
    else
      enc_buffer.zip(hex_buffer, bin_buffer, separator).flatten.join("\n")
    end
  end

  def self.random_color
    "%.2x%.2x%.2x" %[rand(90) + 60, rand(90) + 60, rand(90) + 60]
  end

  def self.symbolify(char)
    return char.inspect unless char.encoding.name[0, 3] == "UTF"
    char
      .tr("\x00-\x1F".encode(char.encoding), "\u{2400}-\u{241F}".encode(char.encoding))
      .gsub(
        Regexp.compile('[\p{Space}᠎​‌‍⁠﻿]'.encode(char.encoding)),
        ']\0['.encode(char.encoding)
      )
      .encode('UTF-8')
  end

  def self.determine_terminal_cols
    cols = STDIN.winsize[1] || 80
  rescue Errno::ENOTTY
    return 80
  end

  def self.help
    puts "Till there is a proper help command implemented, more info at:"
    puts "- https://github.com/janlelis/unibits"
    puts
    puts "Supported encodings: #{SUPPORTED_ENCODINGS.join(', ')}"
  end
end
