/*
 * Imports
 */

import "./parsingError" for ParsingError
import "./tokens" for Tokens, ValueTypes
import "./util" for Util


/*
 * Constants
 */

var Comma = Tokens["Comma"].value
var Comment = Tokens["Comment"].value
var Dot = Tokens["Dot"].value
var EOF = Tokens["End"].value
var Equal = Tokens["Equal"].value
var Key = Tokens["Key"].value
var LeftBrace = Tokens["LeftBrace"].value
var LeftBracket = Tokens["LeftBracket"].value
var RightBrace = Tokens["RightBrace"].value
var RightBracket = Tokens["RightBracket"].value
var TString = Tokens["String"].value


/*
 * Structures
 */

class TOMLParser {


  /*
   * Methods
   */

  construct new (tokens, input) {
    _cursor = 0
    _input = input
    _start = 0
    _tokens = tokens
  }


  isAtEnd (n) {

    if (n < 0 && _cursor - n < 0) {
      Fiber.abort("Cursor out of range at index: %(_cursor - n)")
    }

    return _cursor + n >= _tokens.count

  }


  isAtEnd () {
    return isAtEnd(0)
  }


  advance () {

    _cursor = _cursor + 1

    return _tokens[_cursor - 1]

  }


  peek (n) {

    if (isAtEnd()) return null

    return _tokens[_cursor + n]

  }


  peek () {
    return peek(0)
  }


  parse () {

    var map = {}

    // Process document root.
    processKeyValuePairs(_tokens, map)

    while (peek().type != EOF) {
      processStructure(_tokens, map)
    }

    return map

  }


  getLastMapInList (list) {

    if (list.count == 0) {
      var t = {}
      list.add(t)
      return t
    } else {
      return list[list.count - 1]
    }

  }


  nestListOrGetExisting (key, map) {

    var l = map[key]

    if (map[key] == null) {
      l = []
      map[key] = l
    }

    return l

  }


  nestMapOrGetExisting (key, map) {

    var m = map[key]

    if (map[key] == null) {
      m = {}
      map[key] = m
    }

    return m

  }


  processArrayOfTables (tokens, map) {

    // Consume `[`.
    advance()

    var key
    var l
    var m

    while (peek().type != RightBracket) {

      key = advance()

      if (key.type == Key) {

        // If final key in our list key, define list at this spot
        if (peek().type == RightBracket) {

          if (map is List) map = getLastMapInList(map)

          l = nestListOrGetExisting(key.value, map)

          if (l is List == false) throwParsingError(key)

          // Add a new `Map` to the list.
          m = {}

          l.add(m)

          map = m

        } else {

          if (map is List) map = getLastMapInList(map)

          map = nestMapOrGetExisting(key.value, map)

        }

      } else if (key.type == Dot) {

        if (peek().type != Key) throwParsingError(peek())

      } else {
        throwParsingError(key)
      }

    }

    // Consume `]]`.
    for (i in 1..2) {

      // Unterminated.
      if (isAtEnd() || (i != 2 && peek().type != RightBracket)) throwParsingError()

      advance()

    }

    processKeyValuePairs(tokens, map)

  }


  processTable (tokens, map) {

    var m
    var n

    while (peek().type != RightBracket) {

      n = advance()

      if (n.type == Key || n.type == TString) {

        if (map is List) map = getLastMapInList(map)

        m = nestMapOrGetExisting(n.value, map)

        if (m is List) m = getLastMapInList(m)

        if (m is Map == false) throwParsingError(n)

        map = m

        if (peek().type != Dot && peek().type != RightBracket) {
          throwParsingError(peek())
        }

      } else if (n.type == Dot) {

        if (peek().type != Key && peek().type != TString) {
          throwParsingError(peek())
        }

      } else {
        throwParsingError(n)
      }

    }

    // Consume `]`.
    advance()

    processKeyValuePairs(tokens, map)

  }


  processStructure (tokens, map) {

    if (tokens.count == 0) throwParsingError()

    var token = advance()

    if (token.type != LeftBracket) throwParsingError(token)

    // Double-bracket ie array of tables.
    peek().type == LeftBracket ?
      processArrayOfTables(tokens, map) :
      processTable(tokens, map)

  }


  consumeComments (tokens) {
    while(peek().type == Comment) advance()
  }


  processKeyValuePairs (tokens, map) {

    var key
    var t

    while (peek().type != LeftBracket && peek().type != RightBrace && peek().type != EOF) {

      if (peek().type == Comment) {
        consumeComments(tokens)
      } else {

        key = advance()

        if (peek().type == Equal) {

          // Consume `=`.
          advance()

          map[key.value] = processValue(tokens, map)

        } else if (peek().type == Dot) {

          // Consume `.`
          advance()

          t = nestMapOrGetExisting(key.value, map)

          processKeyValuePairs(tokens, t)

        } else {
          throwParsingError(peek())
        }

      }

    }

  }


  processArray (tokens, map) {

    var list = []

    while (peek().type != RightBracket) {

      list.add(processValue(tokens, map))

      if (peek().type == Comma) {

        // Consume comma.
        advance()

        if (peek().type == RightBracket) throwParsingError(peek())

      }

    }

    if (peek().type != RightBracket) throwParsingError(peek())

    // Consume `]`.
    advance()

    return list

  }


  processInlineTable (tokens, map) {

    var m = {}

    var key

    while (peek().type != RightBrace) {

      if (peek().type == Comment) {
        consumeComments(tokens)
      } else {

        key = advance()

        if (peek().type == Equal) {

          // Consume `=`.
          advance()

          m[key.value] = processValue(tokens, m)

          if (peek().type == Comma) {

            // Consume comma.
            advance()

            if (peek().type == RightBracket) throwParsingError(peek())

          }

        } else if (peek().type == Dot) {

          // Consume `.`.
          advance()

          map = nestMapOrGetExisting(key.value, m)

          processKeyValuePairs(tokens, map)

        } else {
          throwParsingError(peek())
        }

      }

    }

    if (peek().type != RightBrace) throwParsingError(peek())

    // Consume `}`.
    advance()

    return m

  }


  processValue (tokens, map) {

    if (tokens.count == 0) throwParsingError()

    var token = advance()
    var type = token.type

    if (ValueTypes.has(type)) {
      return token.value
    } else if (type == LeftBracket) {
      return processArray(tokens, map)
    } else if (type == LeftBrace) {
      return processInlineTable(tokens, map)
    } else if (type == Comment) {
      consumeComments(tokens)
    } else {
      throwParsingError(token)
    }

  }


  throwParsingError (token) {

    var position = Util.getPositionForIndex(_input, token.index)

    ParsingError.throw(token.value, position["line"], position["column"])

  }


  throwParsingError () {
    ParsingError.throw()
  }


}
