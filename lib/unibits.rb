require_relative "unibits/version"

require "io/console"
require "paint"
require "unicode/display_width"
require "characteristics"
require "symbolify"

module Unibits
  SUPPORTED_ENCODINGS = Encoding.name_list.grep(
    Regexp.union(
      /^UTF-8$/,
      /^UTF8-/,
      /^UTF-...E$/,
      /^ASCII-8BIT$/,
      /^US-ASCII$/,
      /^ISO-8859-/,
      /^Windows-125/,
      /^IBM/,
      /^CP85/,
      /^mac/,
      /^TIS-620$/,
      /^Windows-874$/,
      /^KOI8/,
    )
  ).sort.freeze

  COLORS = {
    invalid: "#FF0000",
    unassigned: "#FF5500",
    control: "#0000FF",
    blank: "#33AADD",
    format: "#FF00FF",
    mark: "#228822",
  }

  DEFAULT_TERMINAL_WIDTH = 80

  def self.of(string, encoding: nil, convert: nil, stats: true, wide_ambiguous: false, width: nil)
    if !string || string.empty?
      raise ArgumentError, "no data given to unibits"
    end

    string = string.dup.force_encoding(encoding) if encoding
    string = string.encode(convert) if convert

    case string.encoding.name
    when *SUPPORTED_ENCODINGS
      puts stats(string, wide_ambiguous: wide_ambiguous) if stats
      puts visualize(string, wide_ambiguous: wide_ambiguous, width: width)
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

  def self.visualize(string, wide_ambiguous: false, width: nil)
    cols = width || determine_terminal_cols
    encoding_name = string.encoding.name

    type = Characteristics.type_from_encoding_name(encoding_name)

    cp_buffer  = ["  "]
    enc_buffer = ["  "]
    hex_buffer = ["  "]
    bin_buffer = ["  "]
    separator  = ["  "]
    current_encoding_error = nil

    puts
    string.each_char{ |char|
      char_info = Characteristics.create_for_type(char, type)
      double_check_utf32_validness!(char, char_info)
      current_color = determine_char_color(char_info)

      current_encoding_error = nil if char_info.valid?

      char.each_byte.with_index{ |byte, byteindex|
        if Paint.unpaint(hex_buffer[-1]).bytesize > cols - 12
          cp_buffer  << "  "
          enc_buffer << "  "
          hex_buffer << "  "
          bin_buffer << "  "
          separator  << "  "
        end

        if byteindex == 0
          if char_info.valid?
            codepoint = "U+%04X" % char.ord
          else
            case encoding_name
            when "US-ASCII"
              codepoint = "invalid"
            when "UTF-8", /^UTF8/
              # this tries to detect what is wrong with this utf-8 encoded string
              # sorry for this mess
              case char.unpack("B*")[0]
              when /^110.{5}$/
                current_encoding_error = [:nec, 1, 1]
                codepoint = "n.e.con."
              when /^1110(.{4})$/
                if $1 == "1101"
                  current_encoding_error = [:nec, 2, 2, :maybe_surrogate]
                else
                  current_encoding_error = [:nec, 2, 2]
                end
                codepoint = "n.e.con."
              when /^11110(.{3})$/
                case $1
                when "100"
                  current_encoding_error = [:nec, 3, 3, :leading_at_max]
                when "101", "110", "111"
                  current_encoding_error = [:nec, 3, 3, :too_large]
                else
                  current_encoding_error = [:nec, 3, 3]
                end
                codepoint = "n.e.con."
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
                    codepoint = "n.e.con."
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
                      if index = cp_buffer[current_cp_buffer_index].rindex("n.e.con.")
                        cp_buffer[current_cp_buffer_index][index..-1] = cp_buffer[current_cp_buffer_index][index..-1].sub("n.e.con.", actual_error)
                      else
                        current_cp_buffer_index -= 1
                        index = cp_buffer[current_cp_buffer_index].rindex("n.e.con.")
                        cp_buffer[current_cp_buffer_index][index..-1] = cp_buffer[current_cp_buffer_index][index..-1].sub("n.e.con.", actual_error)
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
              elsif char.b[encoding_name == 'UTF-16LE' ? 1 : 0].unpack("B*")[0][0, 5] == "11011"
                codepoint = "hlf.srg."
              else
                codepoint = "invalid"
              end
            when 'UTF-32LE', 'UTF-32BE'
              if char.bytesize % 4 != 0
                codepoint = "incompl."
              elsif char.b.unpack("C*")[encoding_name == 'UTF-32LE' ? 2 : 1] > 16 ||
                    char.b.unpack("C*")[encoding_name == 'UTF-32LE' ? 3 : 0] > 0
                codepoint = "toolarge"
              else
                codepoint = "sur.gate"
              end
            end
          end

          cp_buffer[-1] << Paint[ codepoint.ljust(10), current_color, :bold ]

          symbolified_char = Symbolify.symbolify(char, char_info)

          if char_info.unicode?
            padding = 10 - Unicode::DisplayWidth.of(symbolified_char, wide_ambiguous ? 2 : 1)
          else
            padding = 10 - symbolified_char.size
          end

          enc_buffer[-1] << Paint[ symbolified_char, current_color ]
          enc_buffer[-1] << " " * padding if padding > 0
        else
          cp_buffer[-1]  << " " * 10
          enc_buffer[-1] << " " * 10
        end

        hex_buffer[-1] << Paint[ ("%02X" % byte).ljust(10, " "), current_color ]

        bin_buffer[-1] << highlight_bits(byte, char, char_info, current_color, byteindex)
        bin_buffer[-1] << "  "
      }
    }

    if type == :unicode
      enc_buffer.zip(cp_buffer, hex_buffer, bin_buffer, separator).flatten.join("\n")
    else
      enc_buffer.zip(hex_buffer, bin_buffer, separator).flatten.join("\n")
    end
  end

  def self.determine_terminal_cols
    STDIN.winsize[1] || DEFAULT_TERMINAL_WIDTH
  rescue Errno::ENOTTY
    return DEFAULT_TERMINAL_WIDTH
  end

  def self.determine_char_color(char_info)
    if !char_info.valid?
      COLORS[:invalid]
    elsif !char_info.assigned?
      COLORS[:unassigned]
    elsif char_info.blank?
      COLORS[:blank]
    elsif char_info.control?
      COLORS[:control]
    elsif char_info.format?
      COLORS[:format]
    elsif char_info.unicode? && char_info.category[0] == "M"
      COLORS[:mark]
    else
      random_color
    end
  end

  def self.random_color
    "%.2x%.2x%.2x" % [rand(90) + 60, rand(90) + 60, rand(90) + 60]
  end

  def self.highlight_bits(byte, char, char_info, current_color, byteindex)
    bin_byte_complete = byte.to_s(2).rjust(8, "0")

    if !char_info.valid?
      bin_byte_1 = bin_byte_complete
      bin_byte_2 = ""
    else
      case char_info.encoding.name
      when 'US-ASCII'
        bin_byte_1 = bin_byte_complete[0...1]
        bin_byte_2 = bin_byte_complete[1...8]
      when 'ASCII-8BIT'
        bin_byte_1 = ""
        bin_byte_2 = bin_byte_complete
      when 'UTF-8', /^UTF8/
        if byteindex == 0
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
        if char.ord <= 0xFFFF || byteindex == 0 || byteindex == 2
          bin_byte_1 = ""
          bin_byte_2 = bin_byte_complete
        else
          bin_byte_complete =~ /^(11011[01])([01]+)$/
          bin_byte_1 = $1
          bin_byte_2 = $2
        end
      when 'UTF-16BE'
        if char.ord <= 0xFFFF || byteindex == 1 || byteindex == 3
          bin_byte_1 = ""
          bin_byte_2 = bin_byte_complete
        else
          bin_byte_complete =~ /^(11011[01])([01]+)$/
          bin_byte_1 = $1
          bin_byte_2 = $2
        end
      else
        bin_byte_1 = ""
        bin_byte_2 = bin_byte_complete
      end
    end

    res = ""
    res << Paint[ bin_byte_1, current_color ]             unless !bin_byte_1 || bin_byte_1.empty?
    res << Paint[ bin_byte_2, current_color, :underline ] unless !bin_byte_2 || bin_byte_2.empty?
    res
  end

  def self.double_check_utf32_validness!(char, char_info)
    return if RUBY_VERSION > "2.4.0" || char_info.encoding.name[0, 6] != "UTF-32" || !char_info.valid?
    byte_values = char.b.unpack("C*")
    le = char_info.encoding.name == 'UTF-32LE'
    if  byte_values[le ? 2 : 1] > 16 ||
        byte_values[le ? 3 : 0] > 0 ||
        byte_values[le ? 1 : 2] >= 216  && byte_values[le ? 1 : 2] <= 223
      char_info.instance_variable_set(:@is_valid, false)
    end
  end
end
