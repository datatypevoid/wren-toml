/*
 * Imports
 */

import "./error" for Error


/*
 * Structures
 */

class ParsingError is Error {


  /*
   * Getters and Setters
   */

  column { _column }

  line { _line }

  value { _value }


  /*
   * Methods
   */

  construct throw (value, line, column) {
    super("Invalid TOML: Unexpected \"%(value)\" at line %(line), column %(column)")
  }


  construct throw () {
    super("Invalid TOML.")
  }


}
