/*
 * Structures
 */

class TOML {


  /*
   * Methods
   */

  construct new (scanner, parser) {
    _parser = parser
    _scanner = scanner
  }


  parse (tokens, input) {
    return _parser.new(tokens, input).parse()
  }


  parse (input) {
    return _parser.new(tokenize(input), input).parse()
  }


  tokenize (input) {
    return _scanner.new(input).tokenize
  }


}
