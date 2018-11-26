/*
 * Imports
 */

import "./parser" for TOMLParser
import "./scanner" for TOMLScanner
import "./stringifier" for TOMLStringifier
import "./toml" for TOML


/*
 * Structures
 */

class TOMLFactory {


  /*
   * Methods
   */

  construct create () {
    _parser = TOMLParser
    _scanner = TOMLScanner
    _stringifier = TOMLStringifier
  }


  new () {
    return TOML.new(_scanner, _parser, _stringifier)
  }


}
