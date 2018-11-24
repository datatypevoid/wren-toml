/*
 * Imports
 */

import "../wren_modules/wren-enum/src/module" for Enum


/*
 * Structures
 */

var Tokens = Enum.new("Token", [
  "Bool",         // 0
  "Comma",        // 1
  "Comment",      // 2
  "Dot",          // 3
  "End",          // 4
  "Equal",        // 5
  "Float",        // 6
  "Integer",      // 7
  "Key",          // 8
  "LeftBrace",    // 9
  "LeftBracket",  // 10
  "RightBrace",   // 11
  "RightBracket", // 12
  "String"        // 13
])


var ValueTypes = Enum.new("ValueTypes", {
  Tokens["Bool"].name: Tokens["Bool"].value,
  Tokens["Float"].name: Tokens["Float"].value,
  Tokens["Integer"].name: Tokens["Integer"].value,
  Tokens["String"].name: Tokens["String"].value
})
