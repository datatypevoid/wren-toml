/*
 * Imports
 */


/*
 * Structures
 */

var CloneList = Fn.new { |list|

  if (list is List == false) {
    Fiber.abort("Expected list to clone.")
  }

  var newList = []

  for (item in list) newList.add(item)

  return newList

}


var IsBasicList = Fn.new { |list|

  for (item in list) {

    if (!IsValueType.call(item) && item is List == false) {
      return false
    }

  }

  return true

}


var IsValueType = Fn.new { |value|
  return value is Num || value is String || value is Bool
}


class TOMLStringifier {


  /*
   * Getters and Setters
   */

  toString {

    var output = TOMLStringifier.m_stringify(_input, _options)

    if (output.startsWith("\n")) {
      output = output.trimStart("\n")
    }

    if (output.endsWith("\n") == false) {
      output = "%(output)\n"
    }

    return output

  }


  /*
   * Public Methods
   */

  construct new (input) {
    _input = input
  }


  construct new (input, options) {
    _input = input
    _options = options
  }


  /*
   * Private Methods
   */

   static m_stringify (object, options) {
     return m_stringify(object, null, options)
   }


  static m_stringify (object, path, options) {

    path = path || []

    if (path is List == false) {
      Fiber.abort("Expected List for path parameter.")
    }

    if (object is Num) {
      return TOMLStringifier.m_stringifyNum(object)
    } else if (object is Bool) {
      return TOMLStringifier.m_stringifyBool(object)
    } else if (object is String) {
      return TOMLStringifier.m_stringifyString(object)
    } else if (object is List) {
      return TOMLStringifier.m_stringifyList(object, options)
    } else if (object is Map) {
      return TOMLStringifier.m_stringifyMap(object, path, options)
    } else if (object is Null) {
      return TOMLStringifier.m_stringifyNull(object)
    } else {
      return TOMLStringifier.m_onUnknownTypeReceived(object)
    }

  }


  static m_stringifyList (list, options) {

    var sub = list.map { |o|
      return o.type == String ?
        "\"%(TOMLStringifier.m_stringify(o, options))\"" :
        TOMLStringifier.m_stringify(o, options)
    }

    return "[" + sub.join(", ") + "]"

  }


  static m_stringifyString (string) {

    var sub = []

    for (char in string) {

      if (char == "\"") {
        sub.add("\\\"")
      } else if (char == "\\") {
        sub.add("\\\\")
      } else if (char == "\b") {
        sub.add("\\b")
      } else if (char == "\f") {
        sub.add("\\f")
      } else if (char == "\n") {
        sub.add("")
      } else if (char == "\r") {
        sub.add("\\r")
      } else if (char == "\t") {
        sub.add("\\t")
      } else {
        sub.add(char)
      }

    }

    if (string.contains(".")) {
      string = "\\\"%(string)\\\""
    }

    return sub.join("")

  }


  static m_stringifyNull () {
    return "\"null\""
  }


  static m_stringifyNum (num) {
    return num.isInfinity ?
      (num > 0 ? "inf" : "-inf") :
      num.toString
  }


  static m_stringifyBool (value) {
    return value.toString
  }


  static m_stringifyMap (map, path, options) {

    var lists = []
    var maps = []
    var values = []

    /*
     * Sort the map's keys into lists; a key will point to a value which is
     * one of the following:
     *   - List (containing objects, ie Maps)
     *   - Map
     *   - Value-type (Bool, Num, String, or Lists containing only value types)
     * We do this to correctly express the object hierarchy in TOML during
     * stringification.
     */
    TOMLStringifier.m_sortKeys(map, lists, maps, values)

    var result
    var sub

    // Parse value types.
    sub = TOMLStringifier.m_stringifyValueTypes(map, path, values, options)
    result = sub.join("")
    if (!result.endsWith("\n")) result = "%(result)\n"

    // Process maps.
    sub = TOMLStringifier.m_stringifyMaps(map, path, maps, options)
    result = "%(result)%(sub.join(""))"
    if (!result.endsWith("\n")) result = "%(result)\n"

    // Process lists.
    sub = TOMLStringifier.m_stringifyLists(map, path, lists, options)
    result = "%(result)%(sub.join(""))"
    if (!result.endsWith("\n")) result = "%(result)\n"

    return result

  }


  static m_onUnknownTypeReceived (object) {

    var value

    var f = Fiber.new { value = object.toString }

    if (f.try()) {
      Fiber.abort("Object does not implement a 'toString' getter.")
    } else {
      return value
    }

  }


  static m_preparePath (list, next, options) {

    var newPath = CloneList.call(list)

    newPath.add(TOMLStringifier.m_stringify(next, options))

    return newPath

  }



  static m_sortKeys (o, lists, maps, values) {

    var keys = o.keys

    var v

    for (key in keys) {

      v = o[key]

      if (IsValueType.call(v)) {
        values.add(key)
      } else if (v is Map) {
        maps.add(key)
      } else if (v is List) {
        IsBasicList.call(v) ? values.add(key) : lists.add(key)
      } else {
        Fiber.abort("Unsupported type for value of %(key).")
      }

    }

  }


  static m_shouldKeyBeQuoted (key) {
    return key.contains("\n") || key.contains(".") || key.contains(" ")
  }


  static m_stringifyValueTypes (o, pathList, values, options) {

    var indent
    var path
    var value
    var key
    var item

    return values.map { |key|

      item = o[key]

      path = TOMLStringifier.m_preparePath(pathList, key, options)

      indent = TOMLStringifier.m_generateIndent(path.count, options)

      key = TOMLStringifier.m_stringify(key, options)

      if (TOMLStringifier.m_shouldKeyBeQuoted(key)) key = "\"%(key)\""

      value = TOMLStringifier.m_stringify(item, options)

      if (item.type == String) value = "\"%(value)\""

      return "\n%(indent)%(key) = %(value)"

    }

  }


  static m_stringifyMaps (o, pathList, maps, options) {

    var indent
    var path

    return maps.map { |key|

      path = TOMLStringifier.m_preparePath(pathList, key, options)

      indent = TOMLStringifier.m_generateIndent(path.count, options)

      return "\n%(indent)[" + path.join(".") + "]%(TOMLStringifier.m_stringify(o[key], path, options))"

    }

  }


  static m_stringifyLists (o, pathList, lists, options) {

    var arrayKey
    var indent
    var objectsList
    var path
    var string

    return lists.map { |key|

      string = ""

      path = TOMLStringifier.m_preparePath(pathList, key, options)

      indent = TOMLStringifier.m_generateIndent(path.count, options)

      arrayKey = "\n%(indent)[[" + path.join(".") + "]]"

      objectsList = o[key]

      for (object in objectsList) {
        string = "%(string)%(arrayKey)%(TOMLStringifier.m_stringify(object, path, options))"
      }

      return string

    }

  }


  /**
   * Generates a tab sequence.
   * @private
   * @param {Num} depth Depth of this tab sequence.
   * @param {Map} options Can have the following optional properties:
   *  - `tabChar` - indicates the character sequence to use when generating the
   *  tab sequnce. Defaults to a single space character.
   * @return {String}
   */
  static m_generateTabSequence (options) {

    options = options || {}
    var tabChar = options["tabChar"] || " "
    var tabDepth = options["tabDepth"] || 2

    var tab = ""

    for (i in 1..tabDepth) tab = "%(tab)%(tabChar)"

    return tab

  }


  /**
   * Generates an indent sequence.
   * @private
   * @param {Num} depth Depth of this indent sequence.
   * @param {Map} options
   * @return {String}
   */
  static m_generateIndent (depth, options) {

    if (depth is Num == false) {
      Fiber.abort("Expected Num type for 'depth' parameter.")
    }

    var tabSequence = TOMLStringifier.m_generateTabSequence(options)

    var indent = ""

    for (i in 1...depth) indent = "%(indent)%(tabSequence)"

    return indent

  }


}
