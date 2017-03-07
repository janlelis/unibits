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

  def self.of(string, encoding: nil, convert: nil, stats: true, wide_ambiguous: false)
    if !string || string.empty?
      raise ArgumentError, "no data given to unibits"
    end

    string = string.dup.force_encoding(encoding) if encoding
    string = string.encode(convert) if convert

    case string.encoding.name
    when *SUPPORTED_ENCODINGS
      puts stats(string, wide_ambiguous: wide_ambiguous) if stats
      puts visualize(string, wide_ambiguous: wide_ambiguous)
    when 'UTF-16', 'UTF-32'
      raise ArgumentError, "unibits only supports #{string.encoding.name} with specified endianess, please use #{string.encoding.name}LE or #{string.encoding.name}BE"
    else
      raise ArgumentError, "unibits does not support strings of encoding #{string.encoding}"
    end
  end

  def self.stats(string, wide_ambiguous: false)
    valid      = string.valid_encoding?
    bytes      = string.bytesize rescue "?"
    codepoints = string.size rescue "?"
    glyphs     = string.scan(Regexp.compile('\X'.encode(string.encoding))).size rescue "?"
    width      = Unicode::DisplayWidth.of(string, wide_ambiguous ? 2 : 1) rescue "?"

    "\n  #{valid ? '' : Paint["Invalid ", :bold, :red]}#{Paint[string.encoding.name, :bold]} (#{bytes}/#{codepoints}/#{glyphs}/#{width})"
  end

  def self.visualize(string, wide_ambiguous: false)
    cols = determine_terminal_cols

    cp_buffer  = ["  "]
    enc_buffer = ["  "]
    hex_buffer = ["  "]
    bin_buffer = ["  "]
    separator  = ["  "]
    current_encoding_error = nil

    puts
    string.each_char{ |char|
      if char.valid_encoding?
        char_valid = true
        current_color = random_color
        current_encoding_error = nil
      else
        char_valid = false
        current_color = :red
      end

      char.each_byte.with_index{ |byte, index|
        if Paint.unpaint(hex_buffer[-1]).bytesize > cols - 12
          cp_buffer  << "  "
          enc_buffer << "  "
          hex_buffer << "  "
          bin_buffer << "  "
          separator  << "  "
        end

        if index == 0
          if char_valid
            codepoint = "U+%04X" % char.ord
          else
            case string.encoding.name
            when "US-ASCII"
              codepoint = "invalid"
            when "UTF-8"
              # this tries to detect what is wrong with this utf-8 encoded string
              # sorry for this mess
              case char.unpack("B*")[0]
              when /^110.{5}$/
                current_encoding_error = [:nec, 1, 1]
                codepoint = "n.e.c."
              when /^1110(.{4})$/
                if $1 == "1101"
                  current_encoding_error = [:nec, 2, 2, :maybe_surrogate]
                else
                  current_encoding_error = [:nec, 2, 2]
                end
                codepoint = "n.e.c."
              when /^11110(.{3})$/
                case $1
                when "100"
                  current_encoding_error = [:nec, 3, 3, :leading_at_max]
                when "101", "110", "111"
                  current_encoding_error = [:nec, 3, 3, :too_large]
                else
                  current_encoding_error = [:nec, 3, 3]
                end
                codepoint = "n.e.c."
              when /^11111.{3}$/
                codepoint = "toolarge"
              when /^10(.{2}).{4}$/
                # uglyhack to fixup that it is not n.e.c, but something different
                if current_encoding_error && current_encoding_error[0] == :nec
                  if current_encoding_error[3] == :leading_at_max
                    if $1 != "00"
                      current_encoding_error[3] = :too_large
                    else
                      current_encoding_error[3] = nil
                    end
                  elsif current_encoding_error[3] == :maybe_surrogate
                    if $1[0] == "1"
                      current_encoding_error[3] = :surrogate
                    else
                      current_encoding_error[3] = nil
                    end
                  end

                  if current_encoding_error[1] > 1
                    current_encoding_error[1] -= 1
                    codepoint = "n.e.c."
                  else
                    case current_encoding_error[3]
                    when :too_large
                      actual_error = "toolarge"
                    when :surrogate
                      actual_error = "sur.gate"
                    else
                      actual_error = "overlong"
                    end
                    current_cp_buffer_index = -1
                    (current_encoding_error[2]).times{
                      if index = cp_buffer[current_cp_buffer_index].rindex("n.e.c.  ")
                        cp_buffer[current_cp_buffer_index][index..-1] = cp_buffer[current_cp_buffer_index][index..-1].sub("n.e.c.  ", actual_error)
                      else
                        current_cp_buffer_index -= 1
                        index = cp_buffer[current_cp_buffer_index].rindex("n.e.c.  ")
                        cp_buffer[current_cp_buffer_index][index..-1] = cp_buffer[current_cp_buffer_index][index..-1].sub("n.e.c.  ", actual_error)
                      end
                      current_encoding_error = [:overlong]
                      codepoint = actual_error
                    }
                  end
                else
                  current_encoding_error = [:unexp]
                  codepoint = "unexp.c."
                end
              else
                current_encoding_error = [:invallid]
                codepoint = "invalid"
              end
            when 'UTF-16LE', 'UTF-16BE'
              if char.bytesize.odd?
                codepoint = "incompl."
              elsif char.b[string.encoding.name == 'UTF-16LE' ? 1 : 0].unpack("B*")[0][0, 5] == "11011"
                codepoint = "hlf.srg."
              else
                codepoint = "invalid"
              end
            when 'UTF-32LE', 'UTF-32BE'
              if char.bytesize != "4"
                codepoint = "incompl."
              else
                codepoint = "invalid"
              end
            end
          end

          cp_buffer[-1] << Paint[
            codepoint.ljust(10), current_color, :bold
          ]

          if char_valid
            symbolified_char = symbolify(char)
          else
            symbolified_char = "�"
          end

          padding = 10 - Unicode::DisplayWidth.of(symbolified_char, wide_ambiguous ? 2 : 1)

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

        if !char_valid
          bin_byte_1 = bin_byte_complete
          bin_byte_2 = ""
        else
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
    STDIN.winsize[1] || 80
  rescue Errno::ENOTTY
    return 80
  end
end
