import file_type
import gleam/json
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn from_string_test() {
  // Test basic format parsing and structure
  let jpeg_result = file_type.from_string("JPEG")
  case jpeg_result {
    file_type.Image(file_type.JPEG, ext, mime) -> {
      ext |> should.equal("jpg")
      case mime {
        file_type.ImageMime("jpeg") -> Nil
        _ -> should.fail()
      }
    }
    _ -> should.fail()
  }

  let mp4_result = file_type.from_string("MP4")
  case mp4_result {
    file_type.Video(file_type.MP4, ext, mime) -> {
      ext |> should.equal("mp4")
      case mime {
        file_type.VideoMime("mp4") -> Nil
        _ -> should.fail()
      }
    }
    _ -> should.fail()
  }

  let pdf_result = file_type.from_string("PDF")
  case pdf_result {
    file_type.Document(file_type.PDF, ext, mime) -> {
      ext |> should.equal("pdf")
      case mime {
        file_type.DocumentMime("pdf") -> Nil
        _ -> should.fail()
      }
    }
    _ -> should.fail()
  }

  // Test case insensitive
  let lowercase_result = file_type.from_string("jpeg")
  case lowercase_result {
    file_type.Image(file_type.JPEG, "jpg", file_type.ImageMime("jpeg")) -> Nil
    _ -> should.fail()
  }

  // Test unknown formats
  let unknown_result = file_type.from_string("XYZ")
  case unknown_result {
    file_type.Unknown(
      "XYZ",
      "xyz",
      file_type.UnknownMime("application/octet-stream"),
    ) -> Nil
    _ -> should.fail()
  }
}

pub fn decoder_test() {
  // Test decoder returns proper FileType structures
  let image_result = json.parse(from: "\"JPEG\"", using: file_type.decoder())
  case image_result {
    Ok(file_type.Image(file_type.JPEG, "jpg", file_type.ImageMime("jpeg"))) ->
      Nil
    _ -> should.fail()
  }

  let video_result = json.parse(from: "\"MP4\"", using: file_type.decoder())
  case video_result {
    Ok(file_type.Video(file_type.MP4, "mp4", file_type.VideoMime("mp4"))) -> Nil
    _ -> should.fail()
  }

  let unknown_result =
    json.parse(from: "\"UNKNOWN\"", using: file_type.decoder())
  case unknown_result {
    Ok(file_type.Unknown(
      "UNKNOWN",
      "unknown",
      file_type.UnknownMime("application/octet-stream"),
    )) -> Nil
    _ -> should.fail()
  }
}

pub fn to_string_test() {
  // Test to_string function works with new structure
  let jpeg_type = file_type.from_string("JPEG")
  file_type.to_string(jpeg_type) |> should.equal("JPEG")

  let mp4_type = file_type.from_string("MP4")
  file_type.to_string(mp4_type) |> should.equal("MP4")

  let pdf_type = file_type.from_string("PDF")
  file_type.to_string(pdf_type) |> should.equal("PDF")

  let unknown_type = file_type.from_string("UNKNOWN")
  file_type.to_string(unknown_type) |> should.equal("UNKNOWN")
}

pub fn get_extension_test() {
  let jpeg_type = file_type.from_string("JPEG")
  file_type.get_extension(jpeg_type) |> should.equal("jpg")

  let png_type = file_type.from_string("PNG")
  file_type.get_extension(png_type) |> should.equal("png")

  let mp4_type = file_type.from_string("MP4")
  file_type.get_extension(mp4_type) |> should.equal("mp4")
}

pub fn get_mime_and_mime_to_string_test() {
  let jpeg_type = file_type.from_string("JPEG")
  let jpeg_mime = file_type.get_mime(jpeg_type)
  file_type.mime_to_string(jpeg_mime) |> should.equal("image/jpeg")

  let mp4_type = file_type.from_string("MP4")
  let mp4_mime = file_type.get_mime(mp4_type)
  file_type.mime_to_string(mp4_mime) |> should.equal("video/mp4")

  let pdf_type = file_type.from_string("PDF")
  let pdf_mime = file_type.get_mime(pdf_type)
  file_type.mime_to_string(pdf_mime) |> should.equal("application/pdf")
}

pub fn roundtrip_test() {
  let test_strings = [
    "JPEG", "PNG", "MP4", "MOV", "MP3", "WAV", "PDF", "ZIP", "UNKNOWN",
  ]

  list.map(test_strings, fn(input) {
    let file_type = file_type.from_string(input)
    let result = file_type.to_string(file_type)
    result |> should.equal(input)
  })
}
