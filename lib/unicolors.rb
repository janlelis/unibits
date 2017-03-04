require_relative "unicolors/version"

require 'io/console'
require 'paint'
require 'unicode/display_width'

module Unicolors
  def self.of(string)

    case string.encoding.name
    when 'UTF-8', 'UTF-16LE', 'UTF-16BE', 'UTF-32LE', 'UTF-32BE'
      visualize(string)
    else
      raise ArgumentError, "Unicolor does not support strings of encoding #{string.encoding}"
    end
  end

  def self.visualize(string)
    cols = STDIN.winsize[1] || 80

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
            ("U+%04X"%char.ord).ljust(10), current_color, :bold
          ]

          symbolified_char = symbolify(char).encode('UTF-8')
          enc_buffer[-1] << Paint[
            symbolified_char, current_color
          ] << " "*(10-Unicode::DisplayWidth.of(symbolified_char))
        else
          cp_buffer[-1]  << " "*10
          enc_buffer[-1] << " "*10
        end

        hex_buffer[-1] << Paint[
          ("%02X" % byte).ljust(10, " "), current_color
        ]

        bin_byte_complete = byte.to_s(2).rjust(8, "0")

        case string.encoding.name
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
        ] unless bin_byte_1.empty?
        bin_buffer[-1] << Paint[
          bin_byte_2, current_color, :underline
        ] unless bin_byte_2.empty?
        bin_buffer[-1] << "  "
      }
    }
    puts enc_buffer.zip(cp_buffer, hex_buffer, bin_buffer, separator).flatten.join("\n")
  end

  def self.random_color
      "%.2x%.2x%.2x" %[rand(90) + 60, rand(90) + 60, rand(90) + 60]
  end

  def self.symbolify(char)
    char
      .gsub(" ".encode(char.encoding), "␣".encode(char.encoding))
      .tr("\0-\x31".encode(char.encoding), "\u{2400}-\u{241f}".encode(char.encoding))
  end
end

