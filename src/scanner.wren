/*
 * Imports
 */

import "./characters" for EscapeCharacters, NumberCharacters, SpecialCharacters, WhitespaceCharacters
import "./scanningError" for ScanningError
import "./token" for Token
import "./tokens" for Tokens
import "./util" for Util


/*
 * Constants
 */

var Comma = Tokens["Comma"].value
var Comment = Tokens["Comment"].value
var Dot = Tokens["Dot"].value
var EOF = Tokens["End"].value
var Equal = Tokens["Equal"].value
var Float = Tokens["Float"].value
var Integer = Tokens["Integer"].value
var Key = Tokens["Key"].value
var LeftBrace = Tokens["LeftBrace"].value
var LeftBracket = Tokens["LeftBracket"].value
var RightBrace = Tokens["RightBrace"].value
var RightBracket = Tokens["RightBracket"].value
var TBool = Tokens["Bool"].value
var TString = Tokens["String"].value

var LowerCaseAPoint = "a".codePoints[0]
var UpperCaseAPoint = "A".codePoints[0]

var LowerCaseZPoint = "z".codePoints[0]
var UpperCaseZPoint = "Z".codePoints[0]


/*
 * Structures
 */

class TOMLScanner {


  /*
   * Getters and Setters
   */

  isAtEnd {
    return _cursor >= _input.count
  }


  tokenize {

    while (!isAtEnd) {
      _start = _cursor
      scanToken()
    }

    addToken(EOF)

    return _tokens

  }


  /*
   * Methods
   */

  construct new (input) {

    _input = input
    _tokens = []

    // First unconsumed character.
    _start = 0

    // Character that will be considered next.
    _cursor = 0

  }


  static isAlpha (char) {

    var pt = char.codePoints[0]

    return (pt >= LowerCaseAPoint && pt <= LowerCaseZPoint) ||
      (pt >= UpperCaseAPoint && pt <= UpperCaseZPoint) ||
      SpecialCharacters.contains(char)

  }


  static isNumeric (char) {
    return NumberCharacters.contains(char)
  }


  static isAlphanumeric (char) {
    return isAlpha(char) || isNumeric(char)
  }


  static isWhitespace (char) {
    return WhitespaceCharacters.contains(char)
  }


  static isEOL (input) {
    return input == "\n"
  }


  advance () {

    _cursor = _cursor + 1

    return _input[_cursor - 1]

  }


  peek () {

    if (isAtEnd) return "\0"

    return _input[_cursor]

  }


  addToken (type) {
    addToken(type, null)
  }


  addToken (type, value) {
    _tokens.add(Token.new(type, value, _cursor))
  }


  scanToken () {

    var char = advance()

    if (TOMLScanner.isAlphanumeric(char)) {
      scanAlphanumeric()
    } else if (TOMLScanner.isWhitespace(char)) {
      // No-op.
    } else if (char == "=") {
      addToken(Equal)
    } else if (char == "\"") {

      if (peek() == "\"") {

        advance()

        if (peek() == "\"") {

          advance()

          scanMultiLineString()

        } else {
          throwScannerError()
        }

      } else {
        scanString()
      }

    } else if (char == "#") {
      scanComment()
    } else if (char == "[") {
      addToken(LeftBracket)
    } else if (char == "]") {
      addToken(RightBracket)
    } else if (char == "'") {
      scanString("'")
    } else if (char == ",") {
      addToken(Comma)
    } else if (char == "{") {
      addToken(LeftBrace)
    } else if (char == "}") {
      addToken(RightBrace)
    } else {
      throwScannerError()
    }

  }


  scanComment () {

    var value = []

    var char

    while (!isAtEnd && !TOMLScanner.isEOL(peek())) {

      char = advance()

      value.add(char)

    }

    addToken(Comment, value.join(""))

  }


  scanNumeric (value) {

    return Num.fromString(
      (value.indexOf("_") > 0 && !value.startsWith("_") && !value.endsWith("_")) ?
        value.replace("_", "") :
        value
    )

  }


  scanDottedKey (value) {

    var subValue = ""

    for (s in value) {

      if (s != ".") {
        subValue = subValue + s
      } else {
        addToken(Key, subValue)
        addToken(Dot)
        subValue = ""
      }

    }

    // Consume final subValue.
    if (subValue != null && subValue != "") {
      addToken(Key, subValue)
    }

  }


  scanKey (value) {
    // Handle dotted keys.
    value.indexOf(".") != -1 ? scanDottedKey(value) : addToken(Key, value)
  }


  scanValue (value) {

    if (value == "true") {
      addToken(TBool, true)
    } else if (value == "false") {
      addToken(TBool, false)
    } else {
      scanKey(value)
    }

  }


  sliceSelectedInput () {
    return slice(_start, _cursor)
  }


  slice (start, length) {
    return Util.slice(_input, start, length).join("")
  }


  scanAlphanumeric () {

    while (TOMLScanner.isAlphanumeric(peek())) advance()

    var value

    // Check if the last character is alphanumeric; if so, attempt to scan it.
    // This handles cases such as when the input ends with a character; ie when
    // ending with a `Bool` like `true`.
    if (isAtEnd) {

      if (TOMLScanner.isAlphanumeric(_input[_input.count - 1])) {

        var f = Fiber.new {
          value = slice(_start, _cursor + 1)
        }

        if (f.try()) value = sliceSelectedInput()

      }

    } else {
      value = sliceSelectedInput()
    }

    var number = scanNumeric(value)

    number == null ? scanValue(value) : addToken(number.isInteger ? Integer : Float, number)

  }


  scanKey () {

    while (TOMLScanner.isAlphanumeric(peek())) advance()

    addToken(Key, sliceSelectedInput())

  }


  scanString () {
    scanString("\"")
  }


  scanUnicode (length) {

    var start = _cursor

    var decimal = Util.hexToDecimal(slice(start, start + length))

    if (decimal == null) throwScannerError()

    _cursor = _cursor + length

    return String.fromCodePoint(decimal)

  }


  scanString (quoteChar) {

    var isEscaping = false
    var value = []

    var char
    var escape

    while ((peek() != quoteChar || isEscaping) && !isAtEnd && peek() != "\n") {

      char = advance()

      if (isEscaping) {

        escape = EscapeCharacters[char]

        if (escape != null) {
          value.add(escape)
        } else if (char == "u" || char == "U") {
          value.add(scanUnicode(char == "u" ? 4 : 8))
        } else {
          throwScannerError()
        }

        isEscaping = false

      } else if (char == "\\") {
        isEscaping = true
      } else {
        value.add(char)
      }

    }

    // Unterminated string.
    if ((peek() != quoteChar && !isAtEnd) || (isAtEnd && _input[_input.count] != quoteChar)) {
      throwScannerError()
    }

    // Consume closing quote.
    advance()

    addToken(TString, value.join(""))

  }


  scanMultiLineString () {

    // Consume opening newline.
    if (peek() == "\n") advance()

    var isEscaping = false
    var value = []

    var char
    var escape

    while ((peek() != "\"" || isEscaping) && !isAtEnd) {

      char = advance()

      if (isEscaping) {

        escape = EscapeCharacters[char]

        if (escape != null) {
          value.add(escape)
        } else if (char == "u" || char == "U") {
          value.add(scanUnicode(char == "u" ? 4 : 8))
        } else {
          throwScannerError()
        }

        isEscaping = false

      } else if (char == "\\") {

        if (peek() == "\n" || peek() == "\"") {
          // Consume `\`.
          advance()
          skipWhitespace()
        } else {
          isEscaping = true
        }

      } else {
        value.add(char)
      }

    }

    // Consume closing quotes.
    for (i in 1..3) {

      // Unterminated string.
      if (isAtEnd || (i != 3 && peek() != "\"")) throwScannerError()

      advance()

    }

    addToken(TString, value.join(""))

  }


  skipWhitespace () {
    while (TOMLScanner.isWhitespace(peek())) advance()
  }


  throwScannerError () {

    var position = Util.getPositionForIndex(_input, _start)
    var value = sliceSelectedInput()

    ScanningError.throw(value, position["line"], position["column"])

  }


}
