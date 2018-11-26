/*
 * Imports
 */

import "../src/module" for TOML


/*
 * Structures
 */

var t0 = "

  # This is a TOML document. Boom.

  key = 42
  key2 = 44.444 # inline comment
  title = \"TOML Example\" # another inline comment
  server = \"192.168.1.1\"
  enabled = true
  disabled = false
  arr = [1, 2, 3]

  hex0 = 0xDEADBEEF
  hex1 = 0xDEAD_BEEF

  int1 = +99
  int2 = 42
  int3 = 0
  int4 = -17

  int5 = 1_000
  int6 = 5_349_221
  int7 = 1_2_3_4_5     # VALID but discouraged

  # fractional
  flt1 = +1.0
  flt2 = 3.1415
  flt3 = -0.01

  # exponent
  flt4 = 5e+22
  flt5 = 1e6
  flt6 = -2E-2

  # both
  flt7 = 6.626e-34

  flt8 = 224_617.445_991_228

  flt9 = -0.0
  flt10 = +0.0

  # infinity
  sf1 = inf  # positive infinity
  sf2 = +inf # positive infinity
  sf3 = -inf # negative infinity

  # not a number
  sf4 = nan  # actual sNaN/qNaN encoding is implementation specific
  sf5 = +nan # same as `nan`
  sf6 = -nan # valid, actual encoding is implementation specific

  name = { first = \"Tom\", last = \"Preston-Werner\" }
  point = { x = 1, y = 2 }
  animal = { type.name = \"pug\" }
  animals = { type.name.n = \"pug\" }

  points = [ { x = 1, y = 2, z = 3 },
           { x = 7, y = 8, z = 9 },
           { x = 2, y = 4, z = 8 } ]

  # Line breaks are OK when inside arrays
  hosts = [
    \"alpha\",
    \"omega\"
  ]

  key = \"value\"
  bare_key = \"value\"
  bare-key = \"value\"
  1234 = \"value\"

  \"127.0.0.1\" = \"value\"
  \"character encoding\" = \"value\"
  \"ʎǝʞ\" = \"value\"
  'key2' = \"value\"
  'quoted \"value\"' = \"value\"
  unicode = \"\\u2669\"

  [test]
    key3 = \"value3\"

    [test.a]
      b = \"c\"

      [test.a.d]
        e = \"f\"

    [test.g]
      h = \"i\"

    [test.g.j]
      k = \"l\"
      m = \"n\"

  [test2]
    key3 = \"value3\"

    [test2.a]
      b = \"c\"

      [test2.a.d]
        e = \"f\"

  [database]
    server = \"192.168.1.1\"
    ports = [ 8001, 8002, 8003 ]
    connection_max = 5000
    connection_min = -2 # Don't ask me how

  [clients]
    data = [ [\"gamma\", \"delta\"], [1, 2] ]

  [[products]]
    name = \"Hammer\"
    sku = 738594937

  [[products]]

  [[products]]
    name = \"Nail\"
    sku = 284758393
    color = \"gray\"

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

  [servers]
    # You can indent as you please. Tabs or spaces. TOML don't care.
    [servers.alpha]
      ip = \"10.0.0.1\"
      dc = \"eqdc10\"

    [servers.beta]
      ip = \"10.0.0.2\"
      dc = \"eqdc10\"

"


System.print("Creating TOML instance...")

var t = TOML.new()

System.print("Tokenizing...")

var tokens = t.tokenize(t0)

System.print("...tokenizing complete... token count: %(tokens.count).")

System.print("Parsing...")

var toml = t.parse(tokens, t0)

System.print("Printing...")

System.print(toml)

System.print("Stringifying result back to TOML...")

var string = t.stringify(toml)

System.print("Printing...")

System.print(string)
