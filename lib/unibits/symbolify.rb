module Unibits
  module Symbolify
    NO_UTF8_CONVERTER = /^(Windows-1258|IBM864|macCentEuro|macThai)/
    ASCII_CHARS = "\x20-\x7E".freeze
    ASCII_CONTROL_CODEPOINTS = "\x00-\x1F\x7F".freeze
    ASCII_CONTROL_SYMBOLS = "\u{2400}-\u{241F}\u{2421}".freeze
    TAGS = "\u{E0021}-\u{E007E}".freeze

    CONTROL_C0_SYMBOLS = [
      "␀",
      "␁",
      "␂",
      "␃",
      "␄",
      "␅",
      "␆",
      "␇",
      "␈",
      "␉",
      "␊",
      "␋",
      "␌",
      "␍",
      "␎",
      "␏",
      "␐",
      "␑",
      "␒",
      "␓",
      "␔",
      "␕",
      "␖",
      "␗",
      "␘",
      "␙",
      "␚",
      "␛",
      "␜",
      "␝",
      "␞",
      "␟",
    ]

    CONTROL_DELETE_SYMBOL = "␡"

    CONTROL_C1_NAMES = {
      0x80 => "PAD",
      0x81 => "HOP",
      0x82 => "BPH",
      0x83 => "NBH",
      0x84 => "IND",
      0x85 => "NEL",
      0x86 => "SSA",
      0x87 => "ESA",
      0x88 => "HTS",
      0x89 => "HTJ",
      0x8A => "VTS",
      0x8B => "PLD",
      0x8C => "PLU",
      0x8D => "RI",
      0x8E => "SS2",
      0x8F => "SS3",
      0x90 => "DCS",
      0x91 => "PU1",
      0x92 => "PU2",
      0x93 => "STS",
      0x94 => "CCH",
      0x95 => "MW",
      0x96 => "SPA",
      0x97 => "EPA",
      0x98 => "SOS",
      0x99 => "SGC",
      0x9A => "SCI",
      0x9B => "CSI",
      0x9C => "ST",
      0x9D => "OSC",
      0x9E => "PM",
      0x9F => "APC",
    }

    INTERESTING_CODEPOINTS = {
      0x180B => "FVS1",
      0x180C => "FVS2",
      0x180D => "FVS3",

      0x200E => "LRM",
      0x200F => "RLM",
      0x202A => "LRE",
      0x202B => "RLE",
      0x202C => "PDF",
      0x202D => "LRO",
      0x202E => "RLO",
      0x2066 => "LRI",
      0x2067 => "RLI",
      0x2068 => "FSI",
      0x2069 => "PDI",

      0xFE00 => "VS1",
      0xFE01 => "VS2",
      0xFE02 => "VS3",
      0xFE03 => "VS4",
      0xFE04 => "VS5",
      0xFE05 => "VS6",
      0xFE06 => "VS7",
      0xFE07 => "VS8",
      0xFE08 => "VS9",
      0xFE09 => "VS10",
      0xFE0A => "VS11",
      0xFE0B => "VS12",
      0xFE0C => "VS13",
      0xFE0D => "VS14",
      0xFE0E => "VS15",
      0xFE0F => "VS16",

      0xE0001 => "LANG TAG",
      0xE0020 => "TAG ␠",
      0xE007F => "TAG ␡",

      0xE0100 => "VS17",
      0xE0101 => "VS18",
      0xE0102 => "VS19",
      0xE0103 => "VS20",
      0xE0104 => "VS21",
      0xE0105 => "VS22",
      0xE0106 => "VS23",
      0xE0107 => "VS24",
      0xE0108 => "VS25",
      0xE0109 => "VS26",
      0xE010A => "VS27",
      0xE010B => "VS28",
      0xE010C => "VS29",
      0xE010D => "VS30",
      0xE010E => "VS31",
      0xE010F => "VS32",
      0xE0110 => "VS33",
      0xE0111 => "VS34",
      0xE0112 => "VS35",
      0xE0113 => "VS36",
      0xE0114 => "VS37",
      0xE0115 => "VS38",
      0xE0116 => "VS39",
      0xE0117 => "VS40",
      0xE0118 => "VS41",
      0xE0119 => "VS42",
      0xE011A => "VS43",
      0xE011B => "VS44",
      0xE011C => "VS45",
      0xE011D => "VS46",
      0xE011E => "VS47",
      0xE011F => "VS48",
      0xE0120 => "VS49",
      0xE0121 => "VS50",
      0xE0122 => "VS51",
      0xE0123 => "VS52",
      0xE0124 => "VS53",
      0xE0125 => "VS54",
      0xE0126 => "VS55",
      0xE0127 => "VS56",
      0xE0128 => "VS57",
      0xE0129 => "VS58",
      0xE012A => "VS59",
      0xE012B => "VS60",
      0xE012C => "VS61",
      0xE012D => "VS62",
      0xE012E => "VS63",
      0xE012F => "VS64",
      0xE0130 => "VS65",
      0xE0131 => "VS66",
      0xE0132 => "VS67",
      0xE0133 => "VS68",
      0xE0134 => "VS69",
      0xE0135 => "VS70",
      0xE0136 => "VS71",
      0xE0137 => "VS72",
      0xE0138 => "VS73",
      0xE0139 => "VS74",
      0xE013A => "VS75",
      0xE013B => "VS76",
      0xE013C => "VS77",
      0xE013D => "VS78",
      0xE013E => "VS79",
      0xE013F => "VS80",
      0xE0140 => "VS81",
      0xE0141 => "VS82",
      0xE0142 => "VS83",
      0xE0143 => "VS84",
      0xE0144 => "VS85",
      0xE0145 => "VS86",
      0xE0146 => "VS87",
      0xE0147 => "VS88",
      0xE0148 => "VS89",
      0xE0149 => "VS90",
      0xE014A => "VS91",
      0xE014B => "VS92",
      0xE014C => "VS93",
      0xE014D => "VS94",
      0xE014E => "VS95",
      0xE014F => "VS96",
      0xE0150 => "VS97",
      0xE0151 => "VS98",
      0xE0152 => "VS99",
      0xE0153 => "VS100",
      0xE0154 => "VS101",
      0xE0155 => "VS102",
      0xE0156 => "VS103",
      0xE0157 => "VS104",
      0xE0158 => "VS105",
      0xE0159 => "VS106",
      0xE015A => "VS107",
      0xE015B => "VS108",
      0xE015C => "VS109",
      0xE015D => "VS110",
      0xE015E => "VS111",
      0xE015F => "VS112",
      0xE0160 => "VS113",
      0xE0161 => "VS114",
      0xE0162 => "VS115",
      0xE0163 => "VS116",
      0xE0164 => "VS117",
      0xE0165 => "VS118",
      0xE0166 => "VS119",
      0xE0167 => "VS120",
      0xE0168 => "VS121",
      0xE0169 => "VS122",
      0xE016A => "VS123",
      0xE016B => "VS124",
      0xE016C => "VS125",
      0xE016D => "VS126",
      0xE016E => "VS127",
      0xE016F => "VS128",
      0xE0170 => "VS129",
      0xE0171 => "VS130",
      0xE0172 => "VS131",
      0xE0173 => "VS132",
      0xE0174 => "VS133",
      0xE0175 => "VS134",
      0xE0176 => "VS135",
      0xE0177 => "VS136",
      0xE0178 => "VS137",
      0xE0179 => "VS138",
      0xE017A => "VS139",
      0xE017B => "VS140",
      0xE017C => "VS141",
      0xE017D => "VS142",
      0xE017E => "VS143",
      0xE017F => "VS144",
      0xE0180 => "VS145",
      0xE0181 => "VS146",
      0xE0182 => "VS147",
      0xE0183 => "VS148",
      0xE0184 => "VS149",
      0xE0185 => "VS150",
      0xE0186 => "VS151",
      0xE0187 => "VS152",
      0xE0188 => "VS153",
      0xE0189 => "VS154",
      0xE018A => "VS155",
      0xE018B => "VS156",
      0xE018C => "VS157",
      0xE018D => "VS158",
      0xE018E => "VS159",
      0xE018F => "VS160",
      0xE0190 => "VS161",
      0xE0191 => "VS162",
      0xE0192 => "VS163",
      0xE0193 => "VS164",
      0xE0194 => "VS165",
      0xE0195 => "VS166",
      0xE0196 => "VS167",
      0xE0197 => "VS168",
      0xE0198 => "VS169",
      0xE0199 => "VS170",
      0xE019A => "VS171",
      0xE019B => "VS172",
      0xE019C => "VS173",
      0xE019D => "VS174",
      0xE019E => "VS175",
      0xE019F => "VS176",
      0xE01A0 => "VS177",
      0xE01A1 => "VS178",
      0xE01A2 => "VS179",
      0xE01A3 => "VS180",
      0xE01A4 => "VS181",
      0xE01A5 => "VS182",
      0xE01A6 => "VS183",
      0xE01A7 => "VS184",
      0xE01A8 => "VS185",
      0xE01A9 => "VS186",
      0xE01AA => "VS187",
      0xE01AB => "VS188",
      0xE01AC => "VS189",
      0xE01AD => "VS190",
      0xE01AE => "VS191",
      0xE01AF => "VS192",
      0xE01B0 => "VS193",
      0xE01B1 => "VS194",
      0xE01B2 => "VS195",
      0xE01B3 => "VS196",
      0xE01B4 => "VS197",
      0xE01B5 => "VS198",
      0xE01B6 => "VS199",
      0xE01B7 => "VS200",
      0xE01B8 => "VS201",
      0xE01B9 => "VS202",
      0xE01BA => "VS203",
      0xE01BB => "VS204",
      0xE01BC => "VS205",
      0xE01BD => "VS206",
      0xE01BE => "VS207",
      0xE01BF => "VS208",
      0xE01C0 => "VS209",
      0xE01C1 => "VS210",
      0xE01C2 => "VS211",
      0xE01C3 => "VS212",
      0xE01C4 => "VS213",
      0xE01C5 => "VS214",
      0xE01C6 => "VS215",
      0xE01C7 => "VS216",
      0xE01C8 => "VS217",
      0xE01C9 => "VS218",
      0xE01CA => "VS219",
      0xE01CB => "VS220",
      0xE01CC => "VS221",
      0xE01CD => "VS222",
      0xE01CE => "VS223",
      0xE01CF => "VS224",
      0xE01D0 => "VS225",
      0xE01D1 => "VS226",
      0xE01D2 => "VS227",
      0xE01D3 => "VS228",
      0xE01D4 => "VS229",
      0xE01D5 => "VS230",
      0xE01D6 => "VS231",
      0xE01D7 => "VS232",
      0xE01D8 => "VS233",
      0xE01D9 => "VS234",
      0xE01DA => "VS235",
      0xE01DB => "VS236",
      0xE01DC => "VS237",
      0xE01DD => "VS238",
      0xE01DE => "VS239",
      0xE01DF => "VS240",
      0xE01E0 => "VS241",
      0xE01E1 => "VS242",
      0xE01E2 => "VS243",
      0xE01E3 => "VS244",
      0xE01E4 => "VS245",
      0xE01E5 => "VS246",
      0xE01E6 => "VS247",
      0xE01E7 => "VS248",
      0xE01E8 => "VS249",
      0xE01E9 => "VS250",
      0xE01EA => "VS251",
      0xE01EB => "VS252",
      0xE01EC => "VS253",
      0xE01ED => "VS254",
      0xE01EE => "VS255",
      0xE01EF => "VS256",
    }.freeze

    INTERESTING_BYTES_ENCODINGS = {
      0xD8 => /^macCroatian/,
      0xF0 => /^mac(Iceland|Roman|Turkish)/,
      0xFD => /^(ISO-8859-8|Windows-(1255|1256))/,
      0xFE => /^(ISO-8859-8|Windows-(1255|1256))/,
    }.freeze

    INTERESTING_BYTES_VALUES = {
      0xD8 => "Logo",
      0xF0 => "Logo",
      0xFD => "LRM",
      0xFE => "RLM",
    }.freeze

    MAC_KEY_SYMBOLS = {
      0x11 => "⌘",
      0x12 => "⇧",
      0x13 => "⌥",
      0x14 => "⌃",
    }

    def self.symbolify(char, char_info)
      if !char_info.valid?
        "�"
      else
        case char_info
        when UnicodeCharacteristics
          Symbolify.unicode(char, char_info)
        when ByteCharacteristics
          Symbolify.byte(char, char_info)
        when AsciiCharacteristics
          Symbolify.ascii(char, char_info)
        else
          Symbolify.binary(char)
        end
      end
    end

    def self.unicode(char, char_info)
      return "n/a" if !char_info.assigned?

      char = char.dup
      ord = char.ord
      encoding = char_info.encoding

      if char_info.delete?
        char = CONTROL_DELETE_SYMBOL
      elsif char_info.c0?
        char = CONTROL_C0_SYMBOLS[ord]
      elsif char_info.c1?
        char = CONTROL_C1_NAMES[ord]
      elsif char_info.blank?
        char = "]".encode(encoding) + char + "[".encode(encoding)
      elsif ord > 917536 && ord < 917631
        char = "TAG ".encode(encoding) +
               char.tr(TAGS.encode(encoding), ASCII_CHARS.encode(encoding))
      else
        char = INTERESTING_CODEPOINTS[char.ord] || char
      end

      char.encode("UTF-8")
    end

    def self.byte(char, char_info)
      return "n/a" if !char_info.assigned?

      ord = char.ord
      encoding = char_info.encoding
      no_converter = !!(NO_UTF8_CONVERTER =~ encoding.name)
      treat_char_unconverted = false

      if char_info.delete?
        char = CONTROL_DELETE_SYMBOL
      elsif char_info.c0?
        if ord >= 0x11 && ord <= 0x14 && encoding.name =~ /^mac/
          char = MAC_KEY_SYMBOLS[ord]
        else
        char = CONTROL_C0_SYMBOLS[ord]
        end
      elsif char_info.c1?
        char = CONTROL_C1_NAMES[ord]
      elsif no_converter
        treat_char_unconverted = true
      elsif char_info.blank?
        char = "]".encode(encoding) + char + "[".encode(encoding)
      elsif INTERESTING_BYTES_ENCODINGS[ord] =~ encoding.name
        char = INTERESTING_BYTES_VALUES[ord]
      end

      if no_converter && treat_char_unconverted
        char.inspect
      else
        char.encode("UTF-8")
      end
    end

    def self.ascii(char, char_info)
      if char_info.delete?
        char = CONTROL_DELETE_SYMBOL
      elsif char_info.c0?
        char = CONTROL_C0_SYMBOLS[char.ord]
      elsif char_info.blank?
        char = "]" + char + "["
      end

      char
    end

    def self.binary(char)
      char.inspect
    end
  end
end
