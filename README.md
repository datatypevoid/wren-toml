# wren-toml

[TOML](https://github.com/toml-lang/toml) parser for [Wren](https://github.com/wren-lang/wren). Parses [TOML v0.5.0](https://github.com/toml-lang/toml/releases/tag/v0.5.0)


## Features

Supports the [TOML v0.5.0](https://github.com/toml-lang/toml/releases/tag/v0.5.0) specification.

The following features of [TOML](https://github.com/toml-lang/toml/releases/tag/v0.5.0) are not yet supported:

- [Binary Notation](https://github.com/toml-lang/toml#integer)
- [Dotted Keys](https://github.com/toml-lang/toml#keys)
- [Literal Strings](https://github.com/toml-lang/toml#string)
- [Local Date-Time](https://github.com/toml-lang/toml#local-date-time)
- [Local Date](https://github.com/toml-lang/toml#local-date)
- [Local Time](https://github.com/toml-lang/toml#local-time)
- [Octal Notation](https://github.com/toml-lang/toml#integer)
- [Offset Date-Time](https://github.com/toml-lang/toml#offset-date-time)


## Getting Started

The [source](https://github.com/datatypevoid/wren-toml/blob/develop/src) files should be dropped into an existing project and the top module imported:

```wren
import "./relative/path/to/wren-toml/module" for TOML
```

Additionally, the dependencies listed in the [package.toml](https://github.com/datatypevoid/wren-toml/blob/develop/package.toml) file should be cloned/downloaded and dropped in a directory named `wren_modules` (create it if it doesn't exist).

> The `wren-test` dependency is only needed if you intend on running the tests.

Alternatively, if utilizing [wrenpm](https://github.com/brandly/wrenpm) for package management in your project, you can add `wren-toml` to your [package.toml](https://github.com/datatypevoid/wren-toml/blob/develop/package.toml) file and install `wren-toml` from within your project root directory with:

```bash
$ wrenpm install
```


## Usage

### Tokenize and Parse

```wren

// Import module.
import "./relative/path/to/wren-toml/module" for TOML

// Load TOML input.
var input = . . .

System.print("Creating TOML instance...")

var toml = TOML.new()

System.print("Tokenizing...")

var tokens = toml.tokenize(input)

System.print("...tokenizing complete... token count: %(tokens.count).")

System.print("Parsing...")

var output = toml.parse(tokens, input)

System.print("Printing output...")

System.print(output)

```

You can also tokenize and parse in one call:

```wren

// Load TOML input.
var input = . . .

System.print("Creating TOML instance...")

var toml = TOML.new()

System.print("Parsing...")

var output = toml.parse(input)

System.print("Printing output...")

System.print(output)

```


### Stringify

```wren

var input = {
  "products": [{
    "name": "Hammer",
    "sku": 738594937
  }, {
    "name": "Plank",
    "sku": 637984168,
    "variety": [{
      "type": "birch"
    }, {
      "type": "maple"
    }]
  }, {
    "name": "Nail",
    "color": "gray",
    "sku": 284758393
  }]
}

System.print("Creating TOML instance...")

var toml = TOML.new()

System.print("Stringifying...")

var output = toml.stringify(input)

System.print("Printing output...")

System.print(output)

```

#### Options

The stringify method accepts an optional `Map` which may contain any of the following configuration options:
- `appendTrailingNewLine` {`Bool`} - Appends a trailing new line character to the stringified output. Defaults to `true`.
- `tabChar` {`String`} - Character sequence to use when generating tabs. Defaults to a single space.
- `tabDepth` {`Num`} - How many tab character sequences should be used per tab. Defaults to `2`.

```wren

var input = { . . . }

System.print("Creating TOML instance...")

var toml = TOML.new()

System.print("Stringifying...")

var output = toml.stringify(input, {
  "appendTrailingNewLine": false,
  "tabChar": "\t",
  "tabDepth": 1
})

System.print("Printing output...")

System.print(output)

```


### Dependencies

-	*wren* - The best way to get `wren` up and running on your machine is to build from source. You can find more details [here](http://wren.io/getting-started.html).
- *git* - Get `git` [from here](http://git-scm.com/download).


### Testing

Test scripts utilize the [wren-test](https://github.com/gsmaverick/wren-test) framework and are stored in the `tests/` [directory](https://github.com/datatypevoid/wren-toml/tree/develop/tests). You can launch the tests with:

```bash
$ wren ./tests/module.wren
```

Note that you must have the [wren-test](https://github.com/gsmaverick/wren-test) framework installed for the tests to run. The fastest way to do this is to build [wrenpm](https://github.com/brandly/wrenpm) and do:

```bash
# from within the root directory of this project:
$ wrenpm install
```


### Examples

Examples live in the `examples/` [directory](https://github.com/datatypevoid/wren-toml/tree/develop/examples). You can run an example with:

```bash
# `file` is the filename of the example you'd like to run.
$ wren ./examples/file.wren
```


## Wren

### Use a Wren-aware editor

We have good experience using these editors:

-	[Atom](https://atom.io/) with the [Wren language package](https://github.com/munificent/wren-atom)


## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [releases on this repository](https://github.com/datatypevoid/wren-toml/releases).


## Authors

* **David Newman** - *Initial development and ongoing maintenance* - [datatypevoid](https://github.com/datatypevoid)

See also the list of [contributors](https://github.com/datatypevoid/wren-toml/blob/develop/contributors.toml) who participated in this project.


## License

This project is licensed under the ISC License - see the [LICENSE](https://github.com/datatypevoid/wren-toml/blob/develop/LICENSE) file for details


## Acknowledgments

* Thanks to [Bob](https://github.com/munificent) and [friends](https://github.com/wren-lang/wren/graphs/contributors) for giving us [Wren](https://github.com/wren-lang/wren).
* Hat tip to anyone whose code was used.
