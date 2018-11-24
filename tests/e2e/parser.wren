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

var PositiveNaN = 0 / 0
var NegativeNaN = PositiveNaN * -1


/*
 * Structures
 */

var resolvePath = Fn.new { |o, path|

  var obj = o

  for (p in path) {
    obj = obj[p]
  }

  return obj

}


var expectString = Fn.new { |o, expected, path|

  var obj = resolvePath.call(o, path)

  Expect.call(obj).toBe(String)
  Expect.call(obj).toEqual(expected)

}


var expectInteger = Fn.new { |o, expected, path|

  var obj = resolvePath.call(o, path)

  Expect.call(obj).toBe(Num)
  Expect.call(obj).toEqual(expected)
  Expect.call(obj.isInteger).toBeTrue

}


var expectFloat = Fn.new { |o, expected, path|

  var obj = resolvePath.call(o, path)

  Expect.call(obj).toBe(Num)
  Expect.call(obj).toEqual(expected)
  Expect.call(obj.isInteger).toBeFalse

}


var expectBool = Fn.new { |o, expected, path|

  var obj = resolvePath.call(o, path)

  Expect.call(obj).toBe(Bool)
  Expect.call(obj).toEqual(expected)

}


var expectMap = Fn.new { |o, path|

  var obj = resolvePath.call(o, path)

  Expect.call(obj).toBe(Map)

}


var expectList = Fn.new { |o, count, path|

  var obj = resolvePath.call(o, path)

  Expect.call(obj).toBe(List)
  Expect.call(obj.count).toEqual(count)

}



var TOMLParserTest = Suite.new("TOML") { |it|


  it.suite("parse (tokens)") { |it|


    it.should("handle basic strings") {

      var toml = T.parse("
        title = \"TOML Example\" # inline comment
        server = \"192.168.1.1\"

        key = \"value0\"
        bare_key = \"value1\"
        bare-key = \"value2\"
        1234 = \"value3\"

        \"127.0.0.1\" = \"value4\"
        \"character encoding\" = \"value5\"
      ")

      expectString.call(toml, "TOML Example", ["title"])
      expectString.call(toml, "192.168.1.1", ["server"])
      expectString.call(toml, "value0", ["key"])
      expectString.call(toml, "value1", ["bare_key"])
      expectString.call(toml, "value2", ["bare-key"])
      expectString.call(toml, "value3", [1234])
      expectString.call(toml, "value4", ["127.0.0.1"])
      expectString.call(toml, "value5", ["character encoding"])

    }


    it.should("handle unicode characters") {
      expectString.call(T.parse("unicode = \"\\u2669\""), "♩", ["unicode"])
    }


    it.should("handle multi-line strings") {

      var input = "
        mstr1 = \"\"\"        This
        is a
        multi-
        line
        string.\"\"\"

        mstr2 = \"\"\"\\
          This \\
          is a \\
          multi-\\
          line \\
          string.\\
        \"\"\"
      "

      var toml = T.parse(input)

      expectString.call(toml, "        This
        is a
        multi-
        line
        string.", ["mstr1"])

      expectString.call(toml, "This is a multi-line string.", ["mstr2"])

    }


    it.should("handle basic integer values") {

      var toml = T.parse("
        int1 = +99
        int2 = 42
        int3 = 0
        int4 = -17
      ")

      expectInteger.call(toml, 99, ["int1"])
      expectInteger.call(toml, 42, ["int2"])
      expectInteger.call(toml, 0, ["int3"])
      expectInteger.call(toml, -17, ["int4"])

    }


    it.should("handle underscore notation for integer values") {

      var toml = T.parse("
        int5 = 1_000
        int6 = 5_349_221
        int7 = 1_2_3_4_5
      ")

      expectInteger.call(toml, 1000, ["int5"])
      expectInteger.call(toml, 5349221, ["int6"])
      expectInteger.call(toml, 12345, ["int7"])

    }


    it.should("handle hexadecimal notation") {

      var toml = T.parse("
        hex1 = 0xDEADBEEF
        hex2 = 0xffffff
      ")

      expectInteger.call(toml, 0xdeadbeef, ["hex1"])
      expectInteger.call(toml, 0xFFFFFF, ["hex2"])

    }


    it.should("handle underscore notation for hexadecimal values") {

      var toml = T.parse("
        hex3 = 0xdead_beef
        hex4 = 0xFFF_FFF
      ")

      expectInteger.call(toml, 0xDEADBEEF, ["hex3"])
      expectInteger.call(toml, 0xffffff, ["hex4"])

    }


    it.should("handle basic floating-point values") {

      var toml = T.parse("
        flt1 = +1.0
        flt2 = 3.14159
        flt3 = -0.01
      ")

      expectInteger.call(toml, 1.0, ["flt1"])
      expectFloat.call(toml, 3.14159, ["flt2"])
      expectFloat.call(toml, -0.01, ["flt3"])

    }


    it.should("handle underscore notation for floating-point values") {
      expectFloat.call(T.parse("flt8 = 224_617.445_991_228"), 224617.445991228, ["flt8"])
    }


    it.should("handle exponential notation for numeric values") {

      var toml = T.parse("
        flt4 = 5e+22
        flt5 = 1e6
        flt6 = -2E-2
        flt7 = 6.626e-34
      ")

      expectInteger.call(toml, 5e22, ["flt4"])
      expectInteger.call(toml, 1e6, ["flt5"])
      expectFloat.call(toml, -2e-2, ["flt6"])
      expectFloat.call(toml, 6.626e-34, ["flt7"])

    }


    it.should("handle values representing infinity") {

      var toml = T.parse("
        sf1 = inf
        sf2 = -inf
        sf3 = +inf
      ")

      expectFloat.call(toml, PositiveInfinity, ["sf1"])
      expectFloat.call(toml, NegativeInfinity, ["sf2"])
      expectFloat.call(toml, PositiveInfinity, ["sf3"])

    }


    it.should("handle NaN values") {

      var toml = T.parse("
        sf4 = nan
        sf5 = -nan
        sf6 = +nan
      ")

      Expect.call(toml["sf4"]).toBe(Num)
      Expect.call(toml["sf4"]).not.toEqual(PositiveNaN)
      Expect.call(toml["sf4"].isInteger).toBeFalse

      Expect.call(toml["sf5"]).toBe(Num)
      Expect.call(toml["sf5"]).not.toEqual(NegativeNaN)
      Expect.call(toml["sf5"].isInteger).toBeFalse

      Expect.call(toml["sf6"]).toBe(Num)
      Expect.call(toml["sf6"]).not.toEqual(PositiveNaN)
      Expect.call(toml["sf6"].isInteger).toBeFalse

    }


    it.should("handle boolean values") {

      var toml = T.parse("
        enabled = true
        disabled = false
      ")

      expectBool.call(toml, true, ["enabled"])
      expectBool.call(toml, false, ["disabled"])

    }


    it.should("handle dotted keys").skip {

      var toml = T.parse("
        physical.color = \"orange\"
        physical.shape = \"round\"
        site.\"google.com\" = true
      ")

      Expect.call(toml).toBe(Map)

      expectMap.call(toml, ["physical"])

      expectString.call(toml, "orange", ["physical", "color"])
      expectString.call(toml, "round", ["physical", "shape"])

      expectMap.call(toml, ["site"])

      expectBool.call(toml, true, ["site", "google.com"])

    }


    it.should("handle basic arrays") {

      var toml = T.parse("
        hosts = [
          \"alpha\",
          \"omega\"
        ]
      ")

      Expect.call(toml).toBe(Map)

      expectList.call(toml, 2, ["hosts"])

      expectString.call(toml, "alpha", ["hosts", 0])
      expectString.call(toml, "omega", ["hosts", 1])

    }


    it.should("handle nested arrays") {

      var toml = T.parse("data = [ [\"gamma\", \"delta\"], [1, 2] ]")

      Expect.call(toml).toBe(Map)

      var data = toml["data"]

      expectList.call(toml, 2, ["data"])

      expectList.call(data, 2, [0])
      expectList.call(data, 2, [1])

      expectString.call(data, "gamma", [0, 0])
      expectString.call(data, "delta", [0, 1])

      expectInteger.call(data, 1, [1, 0])
      expectInteger.call(data, 2, [1, 1])

    }


    it.should("handle basic tables") {

      var toml = T.parse("
        [database]
          server = \"192.168.1.1\"
          ports = [ 8001, 8002, 8003 ]
          connection_max = 5000
          connection_min = -2 # Don't ask me how
      ")

      Expect.call(toml).toBe(Map)

      var database = toml["database"]

      expectMap.call(toml, ["database"])

      expectString.call(database, "192.168.1.1", ["server"])

      expectList.call(database, 3, ["ports"])

      expectInteger.call(database, 8001, ["ports", 0])
      expectInteger.call(database, 8002, ["ports", 1])
      expectInteger.call(database, 8003, ["ports", 2])

      expectInteger.call(database, 5000, ["connection_max"])
      expectInteger.call(database, -2, ["connection_min"])

    }


    it.should("handle nested tables") {

      var toml = T.parse("
        [servers]
          # You can indent as you please. Tabs or spaces. TOML don't care.
          [servers.alpha]
            ip = \"10.0.0.1\"
            dc = \"eqdc10\"

          [servers.beta]
            ip = \"10.0.0.2\"
            dc = \"eqdc10\"
      ")

      Expect.call(toml).toBe(Map)

      var servers = toml["servers"]

      expectMap.call(toml, ["servers"])

      var alpha = servers["alpha"]

      expectMap.call(servers, ["alpha"])

      expectString.call(alpha, "10.0.0.1", ["ip"])
      expectString.call(alpha, "eqdc10", ["dc"])

      var beta = servers["beta"]

      expectMap.call(servers, ["beta"])

      expectString.call(beta, "10.0.0.2", ["ip"])
      expectString.call(beta, "eqdc10", ["dc"])


    }


    it.should("handle basic arrays of tables") {

      var toml = T.parse("
        [[products]]
          name = \"Hammer\"
          sku = 738594937

        [[products]]

        [[products]]
          name = \"Nail\"
          sku = 284758393
          color = \"gray\"
      ")

      Expect.call(toml).toBe(Map)

      var products = toml["products"]

      expectList.call(toml, 3, ["products"])

      var product0 = products[0]

      expectMap.call(products, [0])

      expectString.call(product0, "Hammer", ["name"])
      expectInteger.call(product0, 738594937, ["sku"])

      var product1 = products[1]

      Expect.call(product1).toBe(Map)

      Expect.call(product1["name"]).toBeNull
      Expect.call(product1["sku"]).toBeNull

      var product2 = products[2]

      expectMap.call(products, [2])

      expectString.call(product2, "Nail", ["name"])
      expectInteger.call(product2, 284758393, ["sku"])
      expectString.call(product2, "gray", ["color"])

    }


    it.should("handle nested arrays of tables") {

      var toml = T.parse("
        [[fruit]]
          name = \"apple\"

          [fruit.physical]
            color = \"red\"
            shape = \"round\"

          [[fruit.variety]]
            name = \"red delicious\"

          [[fruit.variety]]
            name = \"granny smith\"

        [[fruit]]
          name = \"banana\"

          [[fruit.variety]]
            name = \"plantain\"
      ")

      Expect.call(toml).toBe(Map)

      var fruit = toml["fruit"]

      expectList.call(toml, 2, ["fruit"])

      var fruit0 = fruit[0]

      expectMap.call(fruit, [0])

      expectString.call(fruit0, "apple", ["name"])

      var fruit0Physical = fruit0["physical"]

      expectMap.call(fruit0, ["physical"])

      expectString.call(fruit0Physical, "red", ["color"])
      expectString.call(fruit0Physical, "round", ["shape"])

      var fruit0Variety = fruit0["variety"]

      expectList.call(fruit0, 2, ["variety"])

      expectMap.call(fruit0Variety, [0])

      expectString.call(fruit0Variety, "red delicious", [0, "name"])

      expectMap.call(fruit0Variety, [1])

      expectString.call(fruit0Variety, "granny smith", [1, "name"])

      var fruit1 = fruit[1]

      expectMap.call(fruit, [1])

      expectString.call(fruit1, "banana", ["name"])

      var fruit1Variety = fruit1["variety"]

      expectList.call(fruit1, 1, ["variety"])

      expectMap.call(fruit1Variety, [0])

      expectString.call(fruit1Variety, "plantain", [0, "name"])

    }


    it.should("handle basic inline tables") {

      var toml = T.parse("name = { first = \"Tom\", last = \"Preston-Werner\" }")

      Expect.call(toml).toBe(Map)

      var name = toml["name"]

      expectMap.call(toml, ["name"])

      expectString.call(name, "Tom", ["first"])
      expectString.call(name, "Preston-Werner", ["last"])

    }


    it.should("handle nested inline tables") {

      var toml = T.parse("
        points = [
          { x = 1, y = 2, z = 3 },
          { x = 7, y = 8, z = 9 },
          { x = 2, y = 4, z = 8 }
        ]
      ")

      Expect.call(toml).toBe(Map)

      var points = toml["points"]

      expectList.call(toml, 3, ["points"])

      var p0 = points[0]

      expectMap.call(points, [0])

      expectInteger.call(p0, 1, ["x"])
      expectInteger.call(p0, 2, ["y"])
      expectInteger.call(p0, 3, ["z"])

      var p1 = points[1]

      expectMap.call(points, [1])

      expectInteger.call(p1, 7, ["x"])
      expectInteger.call(p1, 8, ["y"])
      expectInteger.call(p1, 9, ["z"])

      var p2 = points[2]

      expectMap.call(points, [1])

      expectInteger.call(p2, 2, ["x"])
      expectInteger.call(p2, 4, ["y"])
      expectInteger.call(p2, 8, ["z"])

    }


    it.should("handle deeply nested inline tables") {

      var toml = T.parse("
        objects = [
          { position = { x = 1, y = 2, z = 3 }, slots = { head = { name = \"helm\" }, body = { name = \"cuirass\" } } },
          { position = { x = 3, y = 6, z = 9 }, slots = { head = { name = \"hat\" }, body = { name = \"tunic\" } } },
          { position = { x = 2, y = 4, z = 8 }, slots = { head = { name = \"circlet\" }, body = { name = \"robe\" } } },
          { a = { b = { c = {} }, h = { i = { j = {} } } }, e = { f = { g = {} }, k = { l = { m = {} } } } }
        ]
      ")

      Expect.call(toml).toBe(Map)

      var objects = toml["objects"]

      expectList.call(toml, 4, ["objects"])

      var o0 = objects[0]

      expectMap.call(objects, [0])
      expectMap.call(objects, [1])
      expectMap.call(objects, [2])
      expectMap.call(objects, [3])

      var p0 = o0["position"]

      expectMap.call(o0, ["position"])

      expectInteger.call(p0, 1, ["x"])
      expectInteger.call(p0, 2, ["y"])
      expectInteger.call(p0, 3, ["z"])

      var slots0 = o0["slots"]

      expectMap.call(o0, ["slots"])

      var head0 = slots0["head"]

      expectMap.call(slots0, ["head"])

      expectString.call(head0, "helm", ["name"])

      var body0 = slots0["body"]

      expectMap.call(slots0, ["body"])

      expectString.call(body0, "cuirass", ["name"])

      var o1 = objects[1]

      var p1 = o1["position"]

      expectMap.call(o1, ["position"])

      expectInteger.call(p1, 3, ["x"])
      expectInteger.call(p1, 6, ["y"])
      expectInteger.call(p1, 9, ["z"])

      var slots1 = o1["slots"]

      expectMap.call(o1, ["slots"])

      var head1 = slots1["head"]

      expectMap.call(slots1, ["head"])

      expectString.call(head1, "hat", ["name"])

      var body1 = slots1["body"]

      expectMap.call(slots1, ["body"])

      expectString.call(body1, "tunic", ["name"])

      var o2 = objects[2]

      var p2 = o2["position"]

      expectMap.call(o2, ["position"])

      expectInteger.call(p2, 2, ["x"])
      expectInteger.call(p2, 4, ["y"])
      expectInteger.call(p2, 8, ["z"])

      var slots2 = o2["slots"]

      expectMap.call(o2, ["slots"])

      var head2 = slots2["head"]

      expectMap.call(slots2, ["head"])

      expectString.call(head2, "circlet", ["name"])

      var body2 = slots2["body"]

      expectMap.call(slots2, ["body"])

      expectString.call(body2, "robe", ["name"])

      var o3 = objects[3]

      expectMap.call(objects, [3])

      expectMap.call(o3, ["a"])
      expectMap.call(o3, ["a", "b"])
      expectMap.call(o3, ["a", "b", "c"])

      expectMap.call(o3, ["a", "h"])
      expectMap.call(o3, ["a", "h", "i"])
      expectMap.call(o3, ["a", "h", "i", "j"])

      expectMap.call(o3, ["e"])
      expectMap.call(o3, ["e", "f"])
      expectMap.call(o3, ["e", "f", "g"])

      expectMap.call(o3, ["e", "k"])
      expectMap.call(o3, ["e", "k", "l"])
      expectMap.call(o3, ["e", "k", "l", "m"])

    }


  }


}
