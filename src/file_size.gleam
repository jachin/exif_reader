import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/string

pub type FileSize {
  FileSize(bytes: Int)
}

/// Convert an ExifTool FileSize string (e.g. "4.3 MB", "1,024 bytes", "2 GiB")
/// into the number of bytes as an Int.
///
/// - Accepts decimal units: kB, MB, GB, TB (base 1000)
/// - Accepts binary units: KiB, MiB, GiB, TiB (base 1024)
/// - Accepts "bytes", "byte", "b"
/// - Ignores spaces and commas
/// - Rounds fractional bytes to the nearest integer
///
/// Examples:
/// - "1,234 kB" -> 1_234_000
/// - "4.3MB" -> 4_300_000
/// - "2 GiB" -> 2_147_483_648
/// - "512 bytes" -> 512
pub fn to_bytes(text: String) -> Result(Int, String) {
  let normalized =
    text
    |> string.trim
    |> string.replace(",", "")
    |> string.replace(" ", "")
    |> string.lowercase

  case split_number_and_unit(normalized) {
    Error(msg) -> Error(msg)
    Ok(#(num_str, unit_str)) -> {
      case unit_factor(unit_str) {
        Error(msg) -> Error(msg)
        Ok(factor) -> {
          case string.split(num_str, ".") {
            // Pure integer amount
            [whole] -> {
              case int.parse(whole) {
                Ok(whole_i) -> Ok(whole_i * factor)
                Error(_) -> Error("Invalid number: " <> num_str)
              }
            }
            // Decimal amount: whole.frac
            [whole, frac] -> {
              case int.parse(whole), int.parse(frac) {
                Ok(whole_i), Ok(frac_i) -> {
                  let denom = pow_i(10, string.length(frac))
                  // Rounded fractional bytes: (frac_i * factor) / denom, rounded
                  let assert Ok(half) = int.divide(denom, 2)
                  let assert Ok(rounded_frac_bytes) =
                    int.divide(frac_i * factor + half, denom)
                  Ok(whole_i * factor + rounded_frac_bytes)
                }
                _, _ -> Error("Invalid number: " <> num_str)
              }
            }
            _ -> Error("Invalid number format: " <> num_str)
          }
        }
      }
    }
  }
}

pub fn decoder() -> decode.Decoder(FileSize) {
  decode.string
  |> decode.then(fn(s) {
    case to_bytes(s) {
      Ok(bytes) -> decode.success(FileSize(bytes))
      Error(_) -> decode.failure(FileSize(0), "Invalid file size format")
    }
  })
}

/// Convert a FileSize to a human-readable string
/// Uses binary units (KiB, MiB, GiB, TiB) with appropriate precision
///
/// Examples:
/// - FileSize(512) -> "512 bytes"
/// - FileSize(1024) -> "1.0 KiB"
/// - FileSize(1536) -> "1.5 KiB"
/// - FileSize(2147483648) -> "2.0 GiB"
pub fn to_string(file_size: FileSize) -> String {
  let FileSize(bytes) = file_size

  case bytes {
    0 -> "0 bytes"
    b if b < 1024 -> int.to_string(b) <> " bytes"
    b if b < 1024 * 1024 -> {
      let kb = int.to_float(b) /. 1024.0
      format_with_unit(kb, "KiB")
    }
    b if b < 1024 * 1024 * 1024 -> {
      let mb = int.to_float(b) /. float_pow(1024.0, 2)
      format_with_unit(mb, "MiB")
    }
    b if b < 1024 * 1024 * 1024 * 1024 -> {
      let gb = int.to_float(b) /. float_pow(1024.0, 3)
      format_with_unit(gb, "GiB")
    }
    b -> {
      let tb = int.to_float(b) /. float_pow(1024.0, 4)
      format_with_unit(tb, "TiB")
    }
  }
}

// ---- Helpers ----

fn split_number_and_unit(s: String) -> Result(#(String, String), String) {
  // Split into numeric prefix (digits + optional '.') and unit suffix
  let graphemes = string.to_graphemes(s)

  let acc =
    list.fold(graphemes, #(True, [], []), fn(acc, ch) {
      let #(in_number, num_rev, unit_rev) = acc
      case in_number {
        True ->
          case is_digit_or_dot(ch) {
            True -> #(True, [ch, ..num_rev], unit_rev)
            False -> #(False, num_rev, [ch, ..unit_rev])
          }
        False -> #(False, num_rev, [ch, ..unit_rev])
      }
    })

  let #(in_number, num_rev, unit_rev) = acc
  let num = num_rev |> list.reverse |> string.join("")
  let unit = unit_rev |> list.reverse |> string.join("")

  case num, unit, in_number {
    // String had only a number, no unit -> treat as bytes
    num_str, "", _ if num_str != "" -> Ok(#(num_str, "b"))
    // Number + unit
    num_str, unit_str, _ if num_str != "" -> Ok(#(num_str, unit_str))
    _, _, _ -> Error("Could not parse size string: " <> s)
  }
}

fn is_digit_or_dot(ch: String) -> Bool {
  case ch {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "." -> True
    _ -> False
  }
}

fn unit_factor(unit: String) -> Result(Int, String) {
  case unit {
    // Bytes
    "" | "b" | "byte" | "bytes" -> Ok(1)

    // Decimal (SI) units - base 1000
    "k" | "kb" -> Ok(1000)
    "m" | "mb" -> Ok(1_000_000)
    "g" | "gb" -> Ok(1_000_000_000)
    "t" | "tb" -> Ok(1_000_000_000_000)

    // Binary (IEC) units - base 1024
    "ki" | "kib" -> Ok(1024)
    "mi" | "mib" -> Ok(1024 * 1024)
    "gi" | "gib" -> Ok(1024 * 1024 * 1024)
    "ti" | "tib" -> Ok(1024 * 1024 * 1024 * 1024)

    _ -> Error("Unknown size unit: " <> unit)
  }
}

fn pow_i(base: Int, exp: Int) -> Int {
  loop(1, exp, base)
}

fn loop(acc: Int, n: Int, base: Int) -> Int {
  case n {
    0 -> acc
    _ -> loop(acc * base, n - 1, base)
  }
}

fn format_with_unit(value: Float, unit: String) -> String {
  case float.truncate(value *. 10.0) % 10 {
    0 -> int.to_string(float.truncate(value)) <> ".0 " <> unit
    _ -> {
      let rounded = int.to_float(float.truncate(value *. 10.0)) /. 10.0
      float.to_string(rounded) <> " " <> unit
    }
  }
}

fn float_pow(base: Float, exp: Int) -> Float {
  float_pow_loop(1.0, exp, base)
}

fn float_pow_loop(acc: Float, n: Int, base: Float) -> Float {
  case n {
    0 -> acc
    _ -> float_pow_loop(acc *. base, n - 1, base)
  }
}
