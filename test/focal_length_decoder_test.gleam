import focal_length
import gleam/json
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn focal_length_decoder_test() {
  let json_strings = [
    #("0", focal_length.FocalLength(0.0)),
    #("0.0", focal_length.FocalLength(0.0)),
    #("\"2\"", focal_length.FocalLength(2.0)),
    #("\"23 mm\"", focal_length.FocalLength(23.0)),
  ]

  list.map(json_strings, fn(t) {
    let #(str, expected_result) = t
    let result = json.parse(from: str, using: focal_length.decoder())
    should.equal(result, Ok(expected_result))
  })
}
