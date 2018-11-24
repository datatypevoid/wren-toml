/*
 * Structures
 */

class Token {


  /*
   * Getters and Setters
   */

  index { _index }

  type { _type }

  value { _value }


  /*
   * Methods
   */

  construct new (type, value, index) {
    _index = index
    _type = type
    _value = value
  }


  toString () {
    return _value == null ? _type : "%(_type) %(value.toString)"
  }


}
