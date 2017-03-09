require "unicode/categories"

module Unibits
  module Symbolify
    ASCII_CONTROL_CODEPOINTS = "\x00-\x1F\x7F".freeze
    ASCII_CONTROL_SYMBOLS = "\u{2400}-\u{241F}\u{2421}".freeze
    ASCII_CHARS = "\x20-\x7E".freeze
    TAG_START = "\u{E0001}".freeze
    TAG_START_SYMBOL = "LANG TAG".freeze
    TAG_SPACE = "\u{E0020}".freeze
    TAG_SPACE_SYMBOL = "TAG ␠".freeze
    TAGS = "\u{E0021}-\u{E007E}".freeze
    TAG_DELETE = "\u{E007F}".freeze
    TAG_DELETE_SYMBOL = "TAG ␡".freeze
    INTERESTING_CODEPOINTS = {
      "\u{0080}" => "PAD",
      "\u{0081}" => "HOP",
      "\u{0082}" => "BPH",
      "\u{0083}" => "NBH",
      "\u{0084}" => "IND",
      "\u{0085}" => "NEL",
      "\u{0086}" => "SSA",
      "\u{0087}" => "ESA",
      "\u{0088}" => "HTS",
      "\u{0089}" => "HTJ",
      "\u{008A}" => "VTS",
      "\u{008B}" => "PLD",
      "\u{008C}" => "PLU",
      "\u{008D}" => "RI",
      "\u{008E}" => "SS2",
      "\u{008F}" => "SS3",
      "\u{0090}" => "DCS",
      "\u{0091}" => "PU1",
      "\u{0092}" => "PU2",
      "\u{0093}" => "STS",
      "\u{0094}" => "CCH",
      "\u{0095}" => "MW",
      "\u{0096}" => "SPA",
      "\u{0097}" => "EPA",
      "\u{0098}" => "SOS",
      "\u{0099}" => "SGC",
      "\u{009A}" => "SCI",
      "\u{009B}" => "CSI",
      "\u{009C}" => "ST",
      "\u{009D}" => "OSC",
      "\u{009E}" => "PM",
      "\u{009F}" => "APC",

      "\u{200E}" => "LRM",
      "\u{200F}" => "RLM",
      "\u{202A}" => "LRE",
      "\u{202B}" => "RLE",
      "\u{202C}" => "PDF",
      "\u{202D}" => "LRO",
      "\u{202E}" => "RLO",
      "\u{2066}" => "LRI",
      "\u{2067}" => "RLI",
      "\u{2068}" => "FSI",
      "\u{2069}" => "PDI",

      "\u{FE00}" => "VS1",
      "\u{FE01}" => "VS2",
      "\u{FE02}" => "VS3",
      "\u{FE03}" => "VS4",
      "\u{FE04}" => "VS5",
      "\u{FE05}" => "VS6",
      "\u{FE06}" => "VS7",
      "\u{FE07}" => "VS8",
      "\u{FE08}" => "VS9",
      "\u{FE09}" => "VS10",
      "\u{FE0A}" => "VS11",
      "\u{FE0B}" => "VS12",
      "\u{FE0C}" => "VS13",
      "\u{FE0D}" => "VS14",
      "\u{FE0E}" => "VS15",
      "\u{FE0F}" => "VS16",
    }.freeze
    COULD_BE_WHITESPACE = '[\p{Space}­᠎​‌‍⁠⁡⁢⁣⁤⁪⁫⁬⁭⁮⁯⠀﻿𛲠𛲡𛲢𛲣𝅳𝅴𝅵𝅶𝅷𝅸𝅹𝅺]'.freeze

    def self.symbolify(char, encoding = char.encoding)
      return "n/a" if Unicode::Categories.category(char) == "Cn"

      char = char.dup

      char.tr!(
        ASCII_CONTROL_CODEPOINTS.encode(encoding),
        ASCII_CONTROL_SYMBOLS.encode(encoding)
      )
      char.gsub!(
        Regexp.compile(COULD_BE_WHITESPACE.encode(encoding)),
        ']\0['.encode(encoding)
      )

      INTERESTING_CODEPOINTS.each{ |cp, desc|
        char.gsub! Regexp.compile(cp.encode(encoding)), desc.encode(encoding)
      }
      char.gsub! TAG_START.encode(encoding), TAG_START_SYMBOL.encode(encoding)
      char.gsub! TAG_SPACE.encode(encoding), TAG_SPACE_SYMBOL.encode(encoding)
      char.gsub! TAG_DELETE.encode(encoding), TAG_DELETE_SYMBOL.encode(encoding)

      ord = char.ord
      if ord > 917536 && ord < 917631
        char.tr!(TAGS.encode(encoding), ASCII_CHARS.encode(encoding))
        char = "TAG ".encode(encoding) + char
      end

      char
    end
  end
end
