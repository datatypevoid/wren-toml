/*
 * Imports
 */

import "../wren_modules/wren-test/dist/module" for ConsoleReporter

// Test suites.
import "./e2e/parser" for TOMLParserTest
import "./e2e/scanner" for TOMLScannerTest
import "./e2e/stringifier" for TOMLStringifierTest


/*
 * Structures
 */

// Store test suites in List.
var tests = [
  TOMLScannerTest,
  TOMLParserTest,
  TOMLStringifierTest
]


var reporter = ConsoleReporter.new()


// Execute tests.
for (test in tests) { test.run(reporter) }
