import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/string

pub type FocalLength {
  FocalLength(mm: Float)
}

pub fn decoder() -> decode.Decoder(FocalLength) {
  decode.one_of(decode.float, [
    decode.int |> decode.map(int.to_float),
    mm_string_decoder(),
  ])
  |> decode.map(fn(f) { FocalLength(f) })
}

fn number_string_to_float(num_str) {
  case float.parse(num_str), int.parse(num_str) {
    Ok(float_value), _ -> {
      Ok(float_value)
    }
    _, Ok(int_value) -> {
      Ok(int.to_float(int_value))
    }
    _, _ -> {
      Error("String is not a valid number")
    }
  }
}

fn mm_string_decoder() {
  decode.string
  |> decode.then(fn(str) {
    case string.split(str, " ") {
      [str_value] -> {
        case number_string_to_float(str_value) {
          Ok(float_value) -> {
            decode.success(float_value)
          }
          Error(_) -> {
            decode.failure(0.0, "Unable to parse focal length")
          }
        }
      }
      [str_value, ""] -> {
        case number_string_to_float(str_value) {
          Ok(float_value) -> {
            decode.success(float_value)
          }
          Error(_) -> {
            decode.failure(0.0, "Unable to parse focal length")
          }
        }
      }
      [str_value, "mm"] -> {
        case number_string_to_float(str_value) {
          Ok(float_value) -> {
            decode.success(float_value)
          }
          Error(_) -> {
            decode.failure(0.0, "Unable to parse focal length")
          }
        }
      }
      _ -> {
        decode.failure(0.0, "Unable to parse focal length")
      }
    }
  })
}

pub fn to_string(fl: FocalLength) {
  case fl {
    FocalLength(fl_str) -> float.to_string(fl_str) <> " mm"
  }
}
