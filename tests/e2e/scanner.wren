/*
 * Imports
 */

import "../../src/module" for TOML
import "../../src/token" for Token
import "../../src/tokens" for Tokens
import "../../wren_modules/wren-test/dist/module" for Expect, Suite


/*
 * Constants
 */

var T = TOML.new()

var PositiveInfinity = 1 / 0
var NegativeInfinity = PositiveInfinity * -1


/*
 * Structures
 */


var readKey = Fn.new { |tokens, expected|

  var token = tokens.removeAt(0)

  Expect.call(token).toBe(Token)

  Expect.call(token.type).toEqual(Tokens["Key"].value)
  Expect.call(token.value).toBe(String)
  Expect.call(token.value).toEqual(expected)

}


var readPunctuation = Fn.new { |tokens, key|

  var token = tokens.removeAt(0)

  Expect.call(token).toBe(Token)

  Expect.call(token.type).toEqual(Tokens[key].value)
  Expect.call(token.value).toBeNull

}


var readInteger = Fn.new { |tokens, expected|

  var token = tokens.removeAt(0)

  Expect.call(token).toBe(Token)

  Expect.call(token.type).toEqual(Tokens["Integer"].value)
  Expect.call(token.value).toBe(Num)
  Expect.call(token.value).toEqual(expected)
  Expect.call(token.value.isInteger).toBeTrue

}


var readFloat = Fn.new { |tokens, expected|

  var token = tokens.removeAt(0)

  Expect.call(token).toBe(Token)

  Expect.call(token.type).toEqual(Tokens["Float"].value)
  Expect.call(token.value).toBe(Num)
  Expect.call(token.value).toEqual(expected)
  Expect.call(token.value.isInteger).toBeFalse

}


var readComment = Fn.new { |tokens, expected|

  var token = tokens.removeAt(0)

  Expect.call(token).toBe(Token)

  Expect.call(token.type).toEqual(Tokens["Comment"].value)
  Expect.call(token.value).toBe(String)
  Expect.call(token.value).toEqual(expected)

}


var readString = Fn.new { |tokens, expected|

  var token = tokens.removeAt(0)

  Expect.call(token).toBe(Token)

  Expect.call(token.type).toEqual(Tokens["String"].value)
  Expect.call(token.value).toBe(String)
  Expect.call(token.value).toEqual(expected)

}


var readBool = Fn.new { |tokens, expected|

  var token = tokens.removeAt(0)

  Expect.call(token).toBe(Token)

  Expect.call(token.type).toEqual(Tokens["Bool"].value)
  Expect.call(token.value).toBe(Bool)
  Expect.call(token.value).toEqual(expected)

}


var readEnd = Fn.new { |tokens|

  var token = tokens.removeAt(0)

  Expect.call(token).toBe(Token)

  Expect.call(token.type).toEqual(Tokens["End"].value)

  Expect.call(tokens.count).toEqual(0)

}


var test = Fn.new { |input, expected|

  var toml = TOML.new()

  if ((input is String) == false) {
    Fiber.abort("Expected 'String' type for 'input' parameter.")
  }

  if ((expected is List) == false) {
    Fiber.abort("Expected 'List' type for 'expected' parameter.")
  }

  var tokens = toml.tokenize(input)

  Expect.call(tokens).toBe(List)

  Expect.call(tokens.count).toEqual(expected.count)

  var token
  var value

  for (e in expected) {

    token = Tokens[e[0]]

    if (token.value == Tokens["Key"].value) {
      readKey.call(tokens, e[1])
    } else if (token.value == Tokens["Equal"].value) {
      readPunctuation.call(tokens, "Equal")
    } else if (token.value == Tokens["Integer"].value) {
      readInteger.call(tokens, e[1])
    } else if (token.value == Tokens["Float"].value) {
      readFloat.call(tokens, e[1])
    } else if (token.value == Tokens["Comment"].value) {
      readComment.call(tokens, e[1])
    } else if (token.value == Tokens["String"].value) {
      readString.call(tokens, e[1])
    } else if (token.value == Tokens["Bool"].value) {
      readBool.call(tokens, e[1])
    } else if (token.value == Tokens["End"].value) {
      readEnd.call(tokens)
    } else if (token.value == Tokens["Dot"].value) {
      readPunctuation.call(tokens, "Dot")
    } else if (token.value == Tokens["LeftBracket"].value) {
      readPunctuation.call(tokens, "LeftBracket")
    } else if (token.value == Tokens["LeftBrace"].value) {
      readPunctuation.call(tokens, "LeftBrace")
    } else if (token.value == Tokens["RightBracket"].value) {
      readPunctuation.call(tokens, "RightBracket")
    } else if (token.value == Tokens["RightBrace"].value) {
      readPunctuation.call(tokens, "RightBrace")
    } else if (token.value == Tokens["Comma"].value) {
      readPunctuation.call(tokens, "Comma")
    } else {
      Fiber.abort("Unexpected token type: %(token.value)")
    }

  }

}


var testNum = Fn.new { |input, expected, isFloat|

  var tokens = T.tokenize("%(input)")

  Expect.call(tokens.count).toEqual(2)

  for (token in tokens) { Expect.call(token).toBe(Token) }

  Expect.call(tokens[0].type).toEqual(Tokens[!isFloat ? "Integer" : "Float"].value)
  Expect.call(tokens[0].value).toBe(Num)
  Expect.call(tokens[0].value).toEqual(expected == null ? Num.fromString(input) : expected)

  isFloat ?
    Expect.call(tokens[0].value.isInteger).toBeFalse :
    Expect.call(tokens[0].value.isInteger).not.toBeFalse

  Expect.call(tokens[1].type).toEqual(Tokens["End"].value)

}


var testString = Fn.new { |input, expected|

  var tokens = T.tokenize("%(input)")

  Expect.call(tokens.count).toEqual(2)

  for (token in tokens) { Expect.call(token).toBe(Token) }

  Expect.call(tokens[0].type).toEqual(Tokens["String"].value)
  Expect.call(tokens[0].value).toBe(String)
  Expect.call(tokens[0].value).toEqual(expected)

  Expect.call(tokens[1].type).toEqual(Tokens["End"].value)

}


var TOMLScannerTest = Suite.new("TOML") { |it|


  it.suite("tokenize (input)") { |it|


    it.should("handle basic strings") {

      testString.call("\"Hello world!\"", "Hello world!")

      testString.call("\"TOML Example\"", "TOML Example")

      testString.call("\"192.168.1.1\"", "192.168.1.1")

    }


    it.should("handle multi-line strings") {

      test.call("
        mstr = \"\"\"
        This
        is a
        multi-
        line
        string.\"\"\"", [
        ["Key", "mstr"],
        ["Equal"],
        ["String", "        This
        is a
        multi-
        line
        string."],
        ["End"]
      ])

      test.call("
        mstr = \"\"\"\\
          This \\
          is a \\
          multi-\\
          line \\
          string.\\
        \"\"\"
      ", [
        ["Key", "mstr"],
        ["Equal"],
        ["String", "This is a multi-line string."],
        ["End"]
      ])

    }


    it.should("handle basic integer values") {

      testNum.call("+99", null, false)

      testNum.call("42", null, false)

      testNum.call("0", null, false)

      testNum.call("-17", null, false)

    }


    it.should("handle underscore notation for integer values") {

      testNum.call("1_000", 1000, false)

      testNum.call("5_349_221", 5349221, false)

      testNum.call("1_2_3_4_5", 12345, false)

    }


    it.should("handle hexadecimal notation") {
      testNum.call("0xDEADBEEF", null, false)
    }


    it.should("handle underscore notation for hexadecimal values") {

      testNum.call("0xfff_fff", 0xffffff, false)

      testNum.call("0xDEAD_BEEF", 0xdeadbeef, false)

    }


    it.should("handle basic floating-point values") {

      testNum.call("+1.1", null, true)

      testNum.call("+0.0", 0.0, false)

      testNum.call("-0.0", -0.0, false)

      testNum.call(Num.pi, Num.fromString("%(Num.pi)"), true)

      testNum.call("-0.01", null, true)

    }


    it.should("handle underscore notation for floating-point values") {
      testNum.call("224_617.445_991_228", 224617.445991228, true)
    }


    it.should("handle exponential notation for numerical values") {

      testNum.call("5e+22", 5e22, false)

      testNum.call("1e6", null, false)

      testNum.call("-2E-2", -2e-2, true)

      testNum.call("6.626e-34", null, true)

    }


    it.should("handle boolean values") {

      var testBool = Fn.new { |input, expected|

        var tokens = T.tokenize("%(input)")

        Expect.call(tokens.count).toEqual(2)

        for (token in tokens) { Expect.call(token).toBe(Token) }

        Expect.call(tokens[0].type).toEqual(Tokens["Bool"].value)
        Expect.call(tokens[0].value).toBe(Bool)
        Expect.call(tokens[0].value).toEqual(expected)

        Expect.call(tokens[1].type).toEqual(Tokens["End"].value)

      }

      testBool.call("true", true)

      testBool.call("false", false)

    }


    it.should("handle values representing infinity") {

      var testInfinity = Fn.new { |input, expected|

        var tokens = T.tokenize("%(input)")

        Expect.call(tokens.count).toEqual(2)

        for (token in tokens) { Expect.call(token).toBe(Token) }

        Expect.call(tokens[0].type).toEqual(Tokens["Float"].value)
        Expect.call(tokens[0].value).toBe(Num)
        Expect.call(tokens[0].value).toEqual(expected)
        Expect.call(tokens[0].value.isInfinity).toBeTrue
        Expect.call(tokens[0].value.isInteger).toBeFalse

        Expect.call(tokens[1].type).toEqual(Tokens["End"].value)

      }

      testInfinity.call("inf", PositiveInfinity)

      testInfinity.call("-inf", NegativeInfinity)

      testInfinity.call("+inf", PositiveInfinity)

    }


    it.should("handle NaN values") {

      var testNaN = Fn.new { |input|

        var tokens = T.tokenize("%(input)")

        Expect.call(tokens.count).toEqual(2)

        for (token in tokens) { Expect.call(token).toBe(Token) }

        Expect.call(tokens[0].type).toEqual(Tokens["Float"].value)
        Expect.call(tokens[0].value).toBe(Num)
        Expect.call(tokens[0].value.isNan).toBeTrue
        Expect.call(tokens[0].value.isInteger).toBeFalse

        Expect.call(tokens[1].type).toEqual(Tokens["End"].value)

      }

      testNaN.call("nan")

      testNaN.call("-nan")

      testNaN.call("+nan")

    }


    it.should("handle unicode characters") {

      test.call("\"\\u2669\"", [
        ["String", "♩"],
        ["End"]
      ])

    }


    it.should("handle basic top-level key/value pairs") {

      test.call("
        key = 42
        key2 = 44.444 # inline comment
        title = \"TOML Example\" # another inline comment
        server = \"192.168.1.1\"
        enabled = true
        disabled = false

        key3 = \"value0\"
        bare_key = \"value1\"
        bare-key = \"value2\"
        1234 = \"value3\"

        \"127.0.0.1\" = \"value4\"
        \"character encoding\" = \"value5\"
      ", [
        ["Key", "key"],
        ["Equal"],
        ["Integer", 42],
        ["Key", "key2"],
        ["Equal"],
        ["Float", 44.444],
        ["Comment", " inline comment"],
        ["Key", "title"],
        ["Equal"],
        ["String", "TOML Example"],
        ["Comment", " another inline comment"],
        ["Key", "server"],
        ["Equal"],
        ["String", "192.168.1.1"],
        ["Key", "enabled"],
        ["Equal"],
        ["Bool", true],
        ["Key", "disabled"],
        ["Equal"],
        ["Bool", false],
        ["Key", "key3"],
        ["Equal"],
        ["String", "value0"],
        ["Key", "bare_key"],
        ["Equal"],
        ["String", "value1"],
        ["Key", "bare-key"],
        ["Equal"],
        ["String", "value2"],
        ["Integer", 1234],
        ["Equal"],
        ["String", "value3"],
        ["String", "127.0.0.1"],
        ["Equal"],
        ["String", "value4"],
        ["String", "character encoding"],
        ["Equal"],
        ["String", "value5"],
        ["End"]
      ])

    }


    it.should("handle dotted keys") {

      test.call("
        physical.color = \"orange\"
        physical.shape = \"round\"
        site.\"google.com\" = true
      ", [
        ["Key", "physical"],
        ["Dot"],
        ["Key", "color"],
        ["Equal"],
        ["String", "orange"],
        ["Key", "physical"],
        ["Dot"],
        ["Key", "shape"],
        ["Equal"],
        ["String", "round"],
        ["Key", "site"],
        ["Dot"],
        ["String", "google.com"],
        ["Equal"],
        ["Bool", true],
        ["End"]
      ])

    }


    it.should("handle basic arrays") {

      test.call("
        hosts = [
          \"alpha\",
          \"omega\"
        ]
      ", [
        ["Key", "hosts"],
        ["Equal"],
        ["LeftBracket"],
        ["String", "alpha"],
        ["Comma"],
        ["String", "omega"],
        ["RightBracket"],
        ["End"]
      ])

    }


    it.should("handle nested arrays") {

      test.call("data = [ [\"gamma\", \"delta\"], [1, 2] ]", [
        ["Key", "data"],
        ["Equal"],
        ["LeftBracket"],
        ["LeftBracket"],
        ["String", "gamma"],
        ["Comma"],
        ["String", "delta"],
        ["RightBracket"],
        ["Comma"],
        ["LeftBracket"],
        ["Integer", 1],
        ["Comma"],
        ["Integer", 2],
        ["RightBracket"],
        ["RightBracket"],
        ["End"]
      ])

    }


    it.should("handle basic tables") {

      test.call("
        [database]
          server = \"192.168.1.1\"
          ports = [ 8001, 8002, 8003 ]
          connection_max = 5000
          connection_min = -2 # Don't ask me how
      ", [
        ["LeftBracket"],
        ["Key", "database"],
        ["RightBracket"],
        ["Key", "server"],
        ["Equal"],
        ["String", "192.168.1.1"],
        ["Key", "ports"],
        ["Equal"],
        ["LeftBracket"],
        ["Integer", 8001],
        ["Comma"],
        ["Integer", 8002],
        ["Comma"],
        ["Integer", 8003],
        ["RightBracket"],
        ["Key", "connection_max"],
        ["Equal"],
        ["Integer", 5000],
        ["Key", "connection_min"],
        ["Equal"],
        ["Integer", -2],
        ["Comment", " Don't ask me how"],
        ["End"]
      ])

    }


    it.should("handle nested tables") {

      test.call("
        [servers]
          # You can indent as you please. Tabs or spaces. TOML don't care.
          [servers.alpha]
            ip = \"10.0.0.1\"
            dc = \"eqdc10\"

          [servers.beta]
            ip = \"10.0.0.2\"
            dc = \"eqdc10\"
      ", [
        ["LeftBracket"],
        ["Key", "servers"],
        ["RightBracket"],
        ["Comment", " You can indent as you please. Tabs or spaces. TOML don't care."],
        ["LeftBracket"],
        ["Key", "servers"],
        ["Dot"],
        ["Key", "alpha"],
        ["RightBracket"],
        ["Key", "ip"],
        ["Equal"],
        ["String", "10.0.0.1"],
        ["Key", "dc"],
        ["Equal"],
        ["String", "eqdc10"],
        ["LeftBracket"],
        ["Key", "servers"],
        ["Dot"],
        ["Key", "beta"],
        ["RightBracket"],
        ["Key", "ip"],
        ["Equal"],
        ["String", "10.0.0.2"],
        ["Key", "dc"],
        ["Equal"],
        ["String", "eqdc10"],
        ["End"]
      ])

      test.call("
        [dog.\"tater.man\"]
          type.name = \"pug\"
      ", [
        ["LeftBracket"],
        ["Key", "dog"],
        ["Dot"],
        ["String", "tater.man"],
        ["RightBracket"],
        ["Key", "type"],
        ["Dot"],
        ["Key", "name"],
        ["Equal"],
        ["String", "pug"],
        ["End"]
      ])

    }


    it.should("handle basic arrays of tables") {

      test.call("
        [[products]]
          name = \"Hammer\"
          sku = 738594937

        [[products]]

        [[products]]
          name = \"Nail\"
          sku = 284758393
          color = \"gray\"
      ", [
        ["LeftBracket"],
        ["LeftBracket"],
        ["Key", "products"],
        ["RightBracket"],
        ["RightBracket"],
        ["Key", "name"],
        ["Equal"],
        ["String", "Hammer"],
        ["Key", "sku"],
        ["Equal"],
        ["Integer", 738594937],
        ["LeftBracket"],
        ["LeftBracket"],
        ["Key", "products"],
        ["RightBracket"],
        ["RightBracket"],
        ["LeftBracket"],
        ["LeftBracket"],
        ["Key", "products"],
        ["RightBracket"],
        ["RightBracket"],
        ["Key", "name"],
        ["Equal"],
        ["String", "Nail"],
        ["Key", "sku"],
        ["Equal"],
        ["Integer", 284758393],
        ["Key", "color"],
        ["Equal"],
        ["String", "gray"],
        ["End"]
      ])

    }


    it.should("handle nested arrays of tables") {

      test.call("
        [[fruit]]
          name = \"apple\"

          [fruit.physical]
            color = \"red\"
            shape = \"round\"

          [[fruit.variety]]
            name = \"red delicious\"

          [[fruit.variety]]
            name = \"granny smith\"
      ", [
        ["LeftBracket"],
        ["LeftBracket"],
        ["Key", "fruit"],
        ["RightBracket"],
        ["RightBracket"],
        ["Key", "name"],
        ["Equal"],
        ["String", "apple"],
        ["LeftBracket"],
        ["Key", "fruit"],
        ["Dot"],
        ["Key", "physical"],
        ["RightBracket"],
        ["Key", "color"],
        ["Equal"],
        ["String", "red"],
        ["Key", "shape"],
        ["Equal"],
        ["String", "round"],
        ["LeftBracket"],
        ["LeftBracket"],
        ["Key", "fruit"],
        ["Dot"],
        ["Key", "variety"],
        ["RightBracket"],
        ["RightBracket"],
        ["Key", "name"],
        ["Equal"],
        ["String", "red delicious"],
        ["LeftBracket"],
        ["LeftBracket"],
        ["Key", "fruit"],
        ["Dot"],
        ["Key", "variety"],
        ["RightBracket"],
        ["RightBracket"],
        ["Key", "name"],
        ["Equal"],
        ["String", "granny smith"],
        ["End"]
      ])

    }


    it.should("handle basic inline tables") {

      test.call("
        name = { first = \"Tom\", last = \"Preston-Werner\" }
      ", [
        ["Key", "name"],
        ["Equal"],
        ["LeftBrace"],
        ["Key", "first"],
        ["Equal"],
        ["String", "Tom"],
        ["Comma"],
        ["Key", "last"],
        ["Equal"],
        ["String", "Preston-Werner"],
        ["RightBrace"],
        ["End"]
      ])

    }


    it.should("handle nested inline tables") {

      test.call("
        points = [
          { x = 1, y = 2, z = 3 },
          { x = 7, y = 8, z = 9 },
          { x = 2, y = 4, z = 8 }
        ]
      ", [
        ["Key", "points"],
        ["Equal"],
        ["LeftBracket"],
        ["LeftBrace"],
        ["Key", "x"],
        ["Equal"],
        ["Integer", 1],
        ["Comma"],
        ["Key", "y"],
        ["Equal"],
        ["Integer", 2],
        ["Comma"],
        ["Key", "z"],
        ["Equal"],
        ["Integer", 3],
        ["RightBrace"],
        ["Comma"],
        ["LeftBrace"],
        ["Key", "x"],
        ["Equal"],
        ["Integer", 7],
        ["Comma"],
        ["Key", "y"],
        ["Equal"],
        ["Integer", 8],
        ["Comma"],
        ["Key", "z"],
        ["Equal"],
        ["Integer", 9],
        ["RightBrace"],
        ["Comma"],
        ["LeftBrace"],
        ["Key", "x"],
        ["Equal"],
        ["Integer", 2],
        ["Comma"],
        ["Key", "y"],
        ["Equal"],
        ["Integer", 4],
        ["Comma"],
        ["Key", "z"],
        ["Equal"],
        ["Integer", 8],
        ["RightBrace"],
        ["RightBracket"],
        ["End"]
      ])

    }


  }


}
