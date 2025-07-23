import exiftool_caller
import gleam/json
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Test parsing a 0
pub fn parse_zero_test() {
  let json_str = "0"

  case json.parse(json_str, exiftool_caller.number_as_float_decoder()) {
    Ok(number) -> {
      should.equal(number, 0.0)
    }
    Error(_) -> should.fail()
  }
}

// Test parsing a 1.1
pub fn parse_one_point_one_test() {
  let json_str = "1.1"

  case json.parse(json_str, exiftool_caller.number_as_float_decoder()) {
    Ok(number) -> {
      should.equal(number, 1.1)
    }
    Error(_) -> should.fail()
  }
}

// Test failing on a string value
pub fn parse_string_fail_test() {
  let json_str = "\"some string\""

  should.be_error(json.parse(
    json_str,
    exiftool_caller.number_as_float_decoder(),
  ))
}

// Test parsing a 1000
pub fn parse_thousand_test() {
  let json_str = "1000"

  case json.parse(json_str, exiftool_caller.number_as_float_decoder()) {
    Ok(number) -> {
      should.equal(number, 1000.0)
    }
    Error(_) -> should.fail()
  }
}
