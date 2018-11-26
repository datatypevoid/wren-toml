/*
 * Structures
 */

class TOML {


  /*
   * Methods
   */

  construct new (scanner, parser, stringifier) {
    _parser = parser
    _scanner = scanner
    _stringifier = stringifier
  }


  parse (tokens, input) {
    return _parser.new(tokens, input).parse()
  }


  parse (input) {
    return _parser.new(tokenize(input), input).parse()
  }


  stringify (input) {
    return _stringifier.new(input, null).toString
  }


  stringify (input, options) {
    return _stringifier.new(input, options).toString
  }


  tokenize (input) {
    return _scanner.new(input).tokenize
  }


}
