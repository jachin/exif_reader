import file_size
import gleam/json
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn to_bytes_test() {
  let test_cases = [
    // Simple bytes
    #("512", Ok(512)),
    #("1024", Ok(1024)),
    #("0", Ok(0)),
    // With explicit byte units
    #("512 bytes", Ok(512)),
    #("1 byte", Ok(1)),
    #("100 b", Ok(100)),
    // Decimal units (base 1000)
    #("1 kB", Ok(1000)),
    #("1 MB", Ok(1_000_000)),
    #("1 GB", Ok(1_000_000_000)),
    #("2.5 kB", Ok(2500)),
    #("4.3 MB", Ok(4_300_000)),
    // Binary units (base 1024)
    #("1 KiB", Ok(1024)),
    #("1 MiB", Ok(1024 * 1024)),
    #("2 GiB", Ok(2_147_483_648)),
    #("1.5 KiB", Ok(1536)),
    // With commas and spaces
    #("1,234 kB", Ok(1_234_000)),
    #("1,024 bytes", Ok(1024)),
    #("4.3MB", Ok(4_300_000)),
    // Case variations
    #("1 kb", Ok(1000)),
    #("1 Mb", Ok(1_000_000)),
    #("1 gb", Ok(1_000_000_000)),
    #("1 kib", Ok(1024)),
    // Error cases
    #("abc", Error("Could not parse size string: abc")),
    #("", Error("Could not parse size string: ")),
    #("1 xyz", Error("Unknown size unit: xyz")),
    #("1.2.3 MB", Error("Invalid number format: 1.2.3")),
  ]

  list.map(test_cases, fn(test_case) {
    let #(input, expected) = test_case
    let result = file_size.to_bytes(input)
    result |> should.equal(expected)
  })
}

pub fn decoder_test() {
  // Success case
  let result = json.parse(from: "\"1.5 MB\"", using: file_size.decoder())
  result |> should.equal(Ok(file_size.FileSize(1_500_000)))

  // Failure case
  let invalid_result =
    json.parse(from: "\"invalid size\"", using: file_size.decoder())
  invalid_result |> should.be_error()
}
