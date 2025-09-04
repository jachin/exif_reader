import exif_reader
import gleam/json
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import tempo/datetime

pub fn main() -> Nil {
  gleeunit.main()
}

// Test parsing a valid datetime with timezone offset
pub fn datetime_with_timezone_offset_test() {
  let json_str = "\"2024:01:15 10:30:00-05:00\""

  case json.parse(json_str, exif_reader.datetime_decoder()) {
    Ok(dt) -> {
      // Should successfully parse the datetime
      let formatted = datetime.to_string(dt)
      string.contains(formatted, "2024-01-15T10:30:00")
      |> should.be_true()
    }
    Error(_) -> should.fail()
  }
}

// Test parsing a datetime with +00:00 timezone (should convert to Z)
pub fn datetime_with_utc_plus_zero_test() {
  let json_str = "\"2024:01:15 10:30:00+00:00\""

  case json.parse(json_str, exif_reader.datetime_decoder()) {
    Ok(dt) -> {
      // Should successfully parse after converting +00:00 to Z
      let formatted = datetime.to_string(dt)
      string.contains(formatted, "2024-01-15T10:30:00")
      |> should.be_true()
    }
    Error(_) -> should.fail()
  }
}

// Test parsing a datetime without timezone
pub fn datetime_without_timezone_test() {
  let json_str = "\"2024:01:15 10:30:00\""

  case json.parse(json_str, exif_reader.datetime_decoder()) {
    Ok(dt) -> {
      // Should successfully parse and assume UTC
      let formatted = datetime.to_string(dt)
      string.contains(formatted, "2024-01-15T10:30:00")
      |> should.be_true()
    }
    Error(_) -> should.fail()
  }
}

// Test parsing a future datetime (tempo can parse future dates)
pub fn datetime_future_date_test() {
  let json_str = "\"2025:07:10 01:31:54+00:00\""

  case json.parse(json_str, exif_reader.datetime_decoder()) {
    Ok(dt) -> {
      // Future dates can actually be parsed by tempo
      let formatted = datetime.to_string(dt)
      string.contains(formatted, "2025-07-10T01:31:54")
      |> should.be_true()
    }
    Error(_) -> should.fail()
  }
}

// Test parsing an invalid datetime format (should fail to parse)
pub fn datetime_invalid_format_test() {
  let json_str = "\"not a valid datetime\""

  case json.parse(json_str, exif_reader.datetime_decoder()) {
    Ok(_) -> {
      // Invalid format should fail to parse entirely
      should.fail()
    }
    Error(_) -> {
      // Expected - invalid format should fail
      Nil
    }
  }
}

// Test the specific problematic datetime formats from the original error
pub fn datetime_problematic_format_future_test() {
  // Test one of the problematic formats from the error message
  let json_str = "\"2025:07:09 20:31:55-05:00\""

  case json.parse(json_str, exif_reader.datetime_decoder()) {
    Ok(dt) -> {
      // Future dates can actually be parsed by tempo
      let formatted = datetime.to_string(dt)
      string.contains(formatted, "2025-07-09T20:31:55")
      |> should.be_true()
    }
    Error(_) -> should.fail()
  }
}

// Test datetime with Z timezone suffix
pub fn datetime_with_z_timezone_test() {
  let json_str = "\"2024:01:15 10:30:00Z\""

  case json.parse(json_str, exif_reader.datetime_decoder()) {
    Ok(dt) -> {
      // Should successfully parse with Z timezone
      let formatted = datetime.to_string(dt)
      string.contains(formatted, "2024-01-15T10:30:00")
      |> should.be_true()
    }
    Error(_) -> should.fail()
  }
}

// Test edge case: datetime at exact epoch
pub fn datetime_epoch_test() {
  let json_str = "\"1970:01:01 00:00:00Z\""

  case json.parse(json_str, exif_reader.datetime_decoder()) {
    Ok(dt) -> {
      // Should parse epoch correctly
      let formatted = datetime.to_string(dt)
      string.contains(formatted, "1970-01-01T00:00:00")
      |> should.be_true()
    }
    Error(_) -> should.fail()
  }
}

// Test multiple problematic formats in sequence
pub fn datetime_multiple_problematic_formats_test() {
  let test_cases = [
    #("\"2025:07:09 20:31:55-05:00\"", False),
    // Future date - should parse successfully
    #("\"2025:07:10 01:31:54+00:00\"", False),
    // Future date with +00:00 - should parse successfully
    #("\"2024:01:01 12:00:00+00:00\"", False),
    // Past date with +00:00 - should parse
    #("\"2024:01:01 12:00:00Z\"", False),
    // Past date with Z - should parse
  ]

  list.each(test_cases, fn(test_case) {
    let #(json_str, should_be_epoch) = test_case

    case json.parse(json_str, exif_reader.datetime_decoder()) {
      Ok(dt) -> {
        let formatted = datetime.to_string(dt)
        case should_be_epoch {
          True -> {
            string.contains(formatted, "1970-01-01T00:00:00")
            |> should.be_true()
          }
          False -> {
            string.contains(formatted, "1970-01-01T00:00:00")
            |> should.be_false()
          }
        }
      }
      Error(_) -> should.fail()
    }
  })
}
