/*
 * Structures
 */

// See: https://github.com/brandly/wren-json/blob/master/json.wren#L342
class Util {


  static slice(list, start) {
    return slice(list, start, list.count)
  }


  static slice(list, start, end) {

    var result = []

    for (index in start...end) {
      result.add(list[index])
    }

    return result

  }


  // shout out to http://www.permadi.com/tutorial/numHexToDec/
  static hexToDecimal (str) {

    var lastIndex = str.count - 1
    var power = 0
    var result = 0

    var num

    for (char in reverse(str)) {

      num = Num.fromString(char)

      if (num == null) return null

      result = result + (num * exponent(16, power))
      power = power + 1

    }

    return result

  }


  static reverse (str) {

    var result = ""

    for (char in str) {
      result = char + result
    }

    return result

  }


  static exponent (value, power) {

    if (power == 0) return 1

    var result = value

    for (i in 1...power) {
      result = result * value
    }

    return result

  }


  static getPositionForIndex (text, index) {

    var precedingText = Util.slice(text, 0, index)
    var linebreaks = precedingText.where {|char| char == "\n"}

    var reversedPreceding = Util.reverse(precedingText)
    var hasSeenLinebreak = false
    var i = 0

    while (i < reversedPreceding.count && !hasSeenLinebreak) {

      if (reversedPreceding[i] == "\n") {
        hasSeenLinebreak = true
      }

      i = i + 1

    }

    return {
      "line": linebreaks.count,
      "column": i
    }

  }


}
