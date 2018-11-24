/*
 * Imports
 */

import "./parser" for TOMLParser
import "./scanner" for TOMLScanner
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
  }


  new () {
    return TOML.new(_scanner, _parser)
  }


}
