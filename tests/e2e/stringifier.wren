/*
 * Imports
 */

import "../../src/module" for TOML
import "../../wren_modules/wren-test/dist/module" for Expect, Suite


/*
 * Constants
 */

var T = TOML.new()

var PositiveInfinity = 1 / 0
var NegativeInfinity = PositiveInfinity * -1


/*
 * Suite
 */

var testBlock = Fn.new { |o, expected|

  var stringified = T.stringify(o)

  var string = ""

  for (e in expected) {

    string = "%(string)%(e)\n"

    Expect.call(
      stringified.indexOf("%(e)") > -1
    ).toBeTrue

  }

  if (stringified.count != string.count) {
    Fiber.abort("Expected the length of the stringified object and the expected length to be equal.")
  }

}


var TOMLStringifierTest = Suite.new("TOML") { |it|


  it.suite("stringify (input)") { |it|


    it.should("handle basic string values") {

      testBlock.call({
        "key": "value",
        "bare_key": "value",
        "bare-key": "value",
        1234: "value",
        "127.0.0.1": "value",
        "character encoding": "value"
      }, [
        "key = \"value\"",
        "bare_key = \"value\"",
        "bare-key = \"value\"",
        "1234 = \"value\"",
        "\"127.0.0.1\" = \"value\"",
        "\"character encoding\" = \"value\""
      ])

    }


    it.should("handle unicode characters") {

      testBlock.call({
        "key": "♩"
      }, [
        "key = \"♩\""
      ])

    }


    it.should("handle basic integer values") {

      testBlock.call({
        "key0": 99,
        "key1": 0,
        "key2": -17
      }, [
        "key0 = 99",
        "key1 = 0",
        "key2 = -17"
      ])

    }


    it.should("handle basic floating-point values") {

      testBlock.call({
        "key0": 1.1,
        "key1": 0.0,
        "key2": -0.0,
        "key3": 3.14159,
        "key4": -0.01,
      }, [
        "key0 = 1.1",
        "key1 = 0",
        "key2 = -0",
        "key3 = 3.14159",
        "key4 = -0.01"
      ])

    }


    it.should("handle exponential notation") {

      testBlock.call({
        "key0": 5e22,
        "key1": 1e6,
        "key2": -2e-2,
        "key3": 6.626e-34
      }, [
        "key0 = 5e+22",
        "key1 = 1000000",
        "key2 = -0.02",
        "key3 = 6.626e-34"
      ])

    }


    it.should("handle values representing infinity") {

      testBlock.call({
        "key0": PositiveInfinity,
        "key1": NegativeInfinity
      }, [
        "key0 = inf",
        "key1 = -inf"
      ])

    }


    it.should("handle NaN values") {

      testBlock.call({
        "key0": Num.fromString("nan"),
        "key1": Num.fromString("-nan")
      }, [
        "key0 = nan",
        "key1 = nan"
      ])

    }


    it.should("handle boolean values") {

      testBlock.call({
        "enabled": true,
        "disabled": false
      }, [
        "enabled = true",
        "disabled = false"
      ])

    }


    it.should("handle an empty basic array") {

      var stringified = T.stringify({
        "array": []
      })

      Expect.call(
        stringified == "array = []\n"
      ).toBeTrue

    }


    it.should("handle a populated basic array") {

      var stringified = T.stringify({
        "array": [
          "string",
          1,
          true,
          false
        ]
      })

      Expect.call(
        stringified == "array = [\"string\", 1, true, false]\n"
      ).toBeTrue

    }


    it.should("handle nested basic arrays") {

      var stringified = T.stringify({
        "array": [
          [0],
          [],
          ["red", "blue"],
          [1, 2],
          [[true], [false]]
        ]
      })

      Expect.call(
        stringified == "array = [[0], [], [\"red\", \"blue\"], [1, 2], [[true], [false]]]\n"
      ).toBeTrue

    }


    it.should("handle an empty table") {

      var stringified = T.stringify({
        "table": {}
      })

      Expect.call(
        stringified == "[table]\n"
      ).toBeTrue

    }


    it.should("handle a table with basic key/value pairs") {

      var o = {
        "table": {
          "enabled": true,
          "server": "127.0.0.1",
          "networkSlop": 512,
          "disabled": false,
          "ports": [5150, 5151, 5152, "*"]
        }
      }

      var stringified = T.stringify(o)

      Expect.call(
        stringified.indexOf("[table]\n") == 0
      ).toBeTrue

      testBlock.call(o, [
        "[table]",
        "  enabled = true",
        "  disabled = false",
        "  server = \"127.0.0.1\"",
        "  networkSlop = 512",
        "  ports = [5150, 5151, 5152, \"*\"]"
      ])

    }


    it.should("handle nested tables") {

      var o = {
        "animal": {
          "type": {
            "name": {
              "n": "pug"
            }
          }
        }
      }

      var stringified = T.stringify(o)

      Expect.call(
        stringified == "[animal]\n\n  [animal.type]\n\n    [animal.type.name]\n      n = \"pug\"\n"
      ).toBeTrue

    }


    it.should("handle arrays of tables") {

      var o = {
        "products": [{
          "name": "Hammer"
        }, {

        }, {
          "name": "Nail"
        }]
      }

      var stringified = T.stringify(o)

      Expect.call(
        stringified == "[[products]]\n" +
          "  name = \"Hammer\"\n" +
          "\n" +
          "[[products]]\n" +
          "\n" +
          "[[products]]\n" +
          "  name = \"Nail\"\n"
      ).toBeTrue

    }


    it.should("handle nested arrays of tables") {

      var o = {
        "fruit": [{
          "name": "apple",
          "physical": {
            "color": "red"
          },
          "variety": [{
            "name": "red delicious"
          }, {
            "name": "granny smith"
          }]
        }, {
          "name": "banana",
          "variety": [{
            "name": "plantain"
          }]
        }]
      }

      var stringified = T.stringify(o)

      Expect.call(
        stringified == "[[fruit]]\n" +
          "  name = \"apple\"\n" +
          "\n" +
          "  [fruit.physical]\n" +
          "    color = \"red\"\n" +
          "\n" +
          "  [[fruit.variety]]\n" +
          "    name = \"red delicious\"\n" +
          "\n" +
          "  [[fruit.variety]]\n" +
          "    name = \"granny smith\"\n" +
          "\n" +
          "[[fruit]]\n" +
          "  name = \"banana\"\n" +
          "\n" +
          "  [[fruit.variety]]\n" +
          "    name = \"plantain\"\n"
      ).toBeTrue

    }


  }


}
