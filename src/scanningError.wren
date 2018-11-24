/*
 * Imports
 */

import "./error" for Error


/*
 * Structures
 */

class ScanningError is Error {

  /*
   * Getters and Setters
   */

  column { _column }

  line { _line }

  value { _value }


  construct new (value, line, column) {

    value = _value
    line = _line
    column = _column

    super("Invalid TOML: Unexpected \"%(value)\" at line %(line), column %(column)")

  }


  construct throw (value, line, column) {
    super("Invalid TOML: Unexpected \"%(value)\" at line %(line), column %(column)")
  }


}
