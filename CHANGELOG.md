## CHANGELOG

### 2.1.0 (next)

* Suppor more encoding: IBMX, CP85X, macX and TIS-620
* Highlight non-control formatting characters in pink

### 2.0.0

* Support more encodings: ISO-8859-X and Windows-125X
* Add three HANGUL characters (U+115F, U+1160, U+3164) to list of possible white spaces
* Move character handling to separate gem. It is called "characteristics".
* Highlight control chars in blue and blanks in light blue
* Handle encodings that are not convertible to UTF-8

### 1.3.0

* Add variation selectors 17-256 (U+E0100 - U+E01EF)
* Add U+1D159 (MUSICAL SYMBOL NULL NOTEHEAD) to list of possible white spaces
* Bump unicode-categories dependency for more reliable unassigned codepoint detection

### 1.2.1

* Fix bug that inserted wrong bytes

### 1.2.0

* Do not display (but highlight) unassigned codepoints

### 1.1.0

* Support (and highlight) invalid encodings \o/
* Improve character symbolification
* Fix that the Kernel method would not take keyword arguments
* New option for setting a custom output width to use
* New option for activating wide ambiguous characters

### 1.0.0

* Initial release

