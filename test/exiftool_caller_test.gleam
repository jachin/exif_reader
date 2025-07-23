//// Tests for exiftool_caller module
////
//// Note: Testing datetime parsing directly is not possible since the
//// datetime_decoder function is not exported. The current implementation
//// handles future dates and problematic timezone formats by falling back
//// to Unix epoch (1970-01-01T00:00:00Z) when tempo fails to parse them.
////
//// This includes:
//// - Future dates that are "out of bounds" for tempo
//// - Dates with +00:00 timezone (converted to Z internally)
//// - Any other unparseable date formats

import exiftool_caller
import gleam/json
import gleam/string
import gleeunit
import gleeunit/should
import tempo/datetime

pub fn main() -> Nil {
  gleeunit.main()
}
