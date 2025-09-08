import argv
import file_size
import file_type
import focal_length
import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import shellout
import tempo
import tempo/datetime
import tempo/error

pub type ExifData {
  ExifData(
    // File information
    source_file: String,
    file_name: String,
    directory: String,
    file_size: file_size.FileSize,
    file_modify_date: tempo.DateTime,
    file_access_date: tempo.DateTime,
    file_inode_change_date: tempo.DateTime,
    file_permissions: String,
    file_type: file_type.FileType,
    file_type_extension: String,
    mime_type: String,
    // Media information
    major_brand: option.Option(String),
    minor_version: option.Option(String),
    compatible_brands: option.Option(List(String)),
    media_data_size: option.Option(Int),
    media_data_offset: option.Option(Int),
    // Movie/Video information
    movie_header_version: option.Option(Int),
    create_date: option.Option(tempo.DateTime),
    modify_date: option.Option(tempo.DateTime),
    time_scale: option.Option(Int),
    duration: option.Option(String),
    preferred_rate: option.Option(Float),
    preferred_volume: option.Option(String),
    preview_time: option.Option(String),
    preview_duration: option.Option(String),
    poster_time: option.Option(String),
    selection_time: option.Option(String),
    selection_duration: option.Option(String),
    current_time: option.Option(String),
    next_track_id: option.Option(Int),
    // Track information
    track_header_version: option.Option(Int),
    track_create_date: option.Option(tempo.DateTime),
    track_modify_date: option.Option(tempo.DateTime),
    track_id: option.Option(Int),
    track_duration: option.Option(String),
    track_layer: option.Option(Int),
    track_volume: option.Option(String),
    // Image/Video dimensions
    image_width: option.Option(Int),
    image_height: option.Option(Int),
    clean_aperture_dimensions: option.Option(String),
    production_aperture_dimensions: option.Option(String),
    encoded_pixels_dimensions: option.Option(String),
    // Graphics and compression
    graphics_mode: option.Option(String),
    op_color: option.Option(String),
    compressor_id: option.Option(String),
    source_image_width: option.Option(Int),
    source_image_height: option.Option(Int),
    x_resolution: option.Option(Int),
    y_resolution: option.Option(Int),
    compressor_name: option.Option(String),
    bit_depth: option.Option(Int),
    video_frame_rate: option.Option(Float),
    // Camera information
    lens_model: option.Option(String),
    lens_model_eng_us: option.Option(String),
    focal_length_in_35mm_format: option.Option(focal_length.FocalLength),
    focal_length_in_35mm_format_eng_us: option.Option(Int),
    // Audio information
    balance: option.Option(Int),
    audio_format: option.Option(String),
    audio_channels: option.Option(Int),
    audio_bits_per_sample: option.Option(Int),
    audio_sample_rate: option.Option(Int),
    purchase_file_format: option.Option(String),
    // Media metadata
    content_describes: option.Option(String),
    matrix_structure: option.Option(String),
    media_header_version: option.Option(Int),
    media_create_date: option.Option(tempo.DateTime),
    media_modify_date: option.Option(tempo.DateTime),
    media_time_scale: option.Option(Int),
    media_duration: option.Option(String),
    media_language_code: option.Option(String),
    // Handler information
    gen_media_version: option.Option(Int),
    gen_flags: option.Option(String),
    gen_graphics_mode: option.Option(String),
    gen_op_color: option.Option(String),
    gen_balance: option.Option(Int),
    handler_class: option.Option(String),
    handler_vendor_id: option.Option(String),
    handler_description: option.Option(String),
    handler_type: option.Option(String),
    meta_format: option.Option(String),
    // Device information
    make: option.Option(String),
    model: option.Option(String),
    software: option.Option(Float),
    // Content metadata
    display_name: option.Option(String),
    description: option.Option(String),
    creation_date: option.Option(tempo.DateTime),
    keywords: option.Option(String),
    // Calculated fields
    image_size: option.Option(String),
    megapixels: option.Option(Float),
    avg_bitrate: option.Option(String),
    rotation: option.Option(Int),
    lens_id: option.Option(String),
    // Tool information
    exif_tool_version: Float,
    warning: option.Option(String),
    full_frame_rate_playback_intent: option.Option(Int),
  )
}

pub fn to_string(exif_data: ExifData) -> String {
  let opt_str = fn(opt: option.Option(String)) -> String {
    case opt {
      option.Some(s) -> s
      option.None -> "missing"
    }
  }

  let opt_float = fn(opt: option.Option(Float)) -> String {
    case opt {
      option.Some(f) -> string.inspect(f)
      option.None -> "missing"
    }
  }

  let opt_int = fn(opt: option.Option(Int)) -> String {
    case opt {
      option.Some(i) -> int.to_string(i)
      option.None -> "missing"
    }
  }

  let opt_datetime = fn(opt: option.Option(tempo.DateTime)) -> String {
    case opt {
      option.Some(dt) -> datetime.to_string(dt)
      option.None -> "missing"
    }
  }

  let opt_focal_length = fn(opt: option.Option(focal_length.FocalLength)) -> String {
    case opt {
      option.Some(fl) -> focal_length.to_string(fl) <> "mm"
      option.None -> "missing"
    }
  }

  let opt_list_str = fn(opt: option.Option(List(String))) -> String {
    case opt {
      option.Some(lst) -> string.join(lst, ", ")
      option.None -> "missing"
    }
  }

  "=== File Information ===\n"
  <> "File: "
  <> exif_data.file_name
  <> "\nPath: "
  <> exif_data.source_file
  <> "\nDirectory: "
  <> exif_data.directory
  <> "\nSize: "
  <> exif_data.file_size |> file_size.to_string
  <> "\nType: "
  <> file_type.to_string(exif_data.file_type)
  <> " ("
  <> exif_data.mime_type
  <> ")"
  <> "\nFile Type Extension: "
  <> exif_data.file_type_extension
  <> "\nModified: "
  <> datetime.to_string(exif_data.file_modify_date)
  <> "\nAccessed: "
  <> datetime.to_string(exif_data.file_access_date)
  <> "\nInode Changed: "
  <> datetime.to_string(exif_data.file_inode_change_date)
  <> "\nPermissions: "
  <> exif_data.file_permissions
  <> "\nCreated: "
  <> opt_datetime(exif_data.creation_date)
  <> "\n\n=== Content ===\n"
  <> "Display Name: "
  <> opt_str(exif_data.display_name)
  <> "\nDescription: "
  <> opt_str(exif_data.description)
  <> "\nKeywords: "
  <> opt_str(exif_data.keywords)
  <> "\n\n=== Video/Image Details ===\n"
  <> "Dimensions: "
  <> opt_str(exif_data.image_size)
  <> "\nWidth: "
  <> opt_int(exif_data.image_width)
  <> "\nHeight: "
  <> opt_int(exif_data.image_height)
  <> "\nMegapixels: "
  <> opt_float(exif_data.megapixels)
  <> "\nDuration: "
  <> opt_str(exif_data.duration)
  <> "\nFrame Rate: "
  <> opt_float(exif_data.video_frame_rate)
  <> " fps"
  <> "\nBitrate: "
  <> opt_str(exif_data.avg_bitrate)
  <> "\nRotation: "
  <> opt_int(exif_data.rotation)
  <> "\nBit Depth: "
  <> opt_int(exif_data.bit_depth)
  <> "\n\n=== Camera ===\n"
  <> "Make: "
  <> opt_str(exif_data.make)
  <> "\nModel: "
  <> opt_str(exif_data.model)
  <> "\nLens Model: "
  <> opt_str(exif_data.lens_model)
  <> "\nLens ID: "
  <> opt_str(exif_data.lens_id)
  <> "\nFocal Length (35mm): "
  <> opt_focal_length(exif_data.focal_length_in_35mm_format)
  <> "\nSoftware: "
  <> opt_float(exif_data.software)
  <> "\n\n=== Media Information ===\n"
  <> "Major Brand: "
  <> opt_str(exif_data.major_brand)
  <> "\nMinor Version: "
  <> opt_str(exif_data.minor_version)
  <> "\nCompatible Brands: "
  <> opt_list_str(exif_data.compatible_brands)
  <> "\nMedia Data Size: "
  <> opt_int(exif_data.media_data_size)
  <> "\nMedia Data Offset: "
  <> opt_int(exif_data.media_data_offset)
  <> "\nCreate Date: "
  <> opt_datetime(exif_data.create_date)
  <> "\nModify Date: "
  <> opt_datetime(exif_data.modify_date)
  <> "\nTime Scale: "
  <> opt_int(exif_data.time_scale)
  <> "\nPreferred Rate: "
  <> opt_float(exif_data.preferred_rate)
  <> "\nPreferred Volume: "
  <> opt_str(exif_data.preferred_volume)
  <> "\n\n=== Audio Information ===\n"
  <> "Audio Format: "
  <> opt_str(exif_data.audio_format)
  <> "\nAudio Channels: "
  <> opt_int(exif_data.audio_channels)
  <> "\nAudio Bits Per Sample: "
  <> opt_int(exif_data.audio_bits_per_sample)
  <> "\nAudio Sample Rate: "
  <> opt_int(exif_data.audio_sample_rate)
  <> "\nBalance: "
  <> opt_int(exif_data.balance)
  <> "\n\n=== Technical Details ===\n"
  <> "Handler Type: "
  <> opt_str(exif_data.handler_type)
  <> "\nHandler Description: "
  <> opt_str(exif_data.handler_description)
  <> "\nCompressor ID: "
  <> opt_str(exif_data.compressor_id)
  <> "\nCompressor Name: "
  <> opt_str(exif_data.compressor_name)
  <> "\nGraphics Mode: "
  <> opt_str(exif_data.graphics_mode)
  <> "\nOp Color: "
  <> opt_str(exif_data.op_color)
  <> "\nExifTool Version: "
  <> string.inspect(exif_data.exif_tool_version)
  <> "\nWarning: "
  <> opt_str(exif_data.warning)
}

pub fn main() -> Nil {
  case argv.load().arguments {
    [file_name] -> {
      case get_media_files_metadata(file_name) {
        Ok(exif_list) -> {
          list.each(exif_list, fn(exif_data) {
            io.println(to_string(exif_data))
            io.println("")
            // Add blank line between files
          })
        }
        Error(_) -> Nil
        // Error already printed in get_media_file_metadata
      }
    }
    _ -> io.println("usage: ./program <file_name>")
  }
}

fn exiftool_json_decoder() -> decode.Decoder(List(ExifData)) {
  decode.list(of: exif_data_decoder())
}

/// Decoder that accepts both int and float values, converting ints to floats
pub fn number_as_float_decoder() -> decode.Decoder(Float) {
  decode.one_of(decode.float, [decode.int |> decode.map(int.to_float)])
}

/// Convert tempo parse error to human-friendly error message
fn format_datetime_parse_error(error: error.DateTimeParseError) -> String {
  case error {
    error.DateTimeInvalidFormat(input) ->
      "Invalid datetime format for \""
      <> input
      <> "\". Expected format: YYYY:MM:DD HH:MM:SS"
    error.DateTimeDateParseError(input, _) ->
      "Month out of bounds in \"" <> input <> "\""
    error.DateTimeTimeParseError(input, _) ->
      "Day out of bounds in \"" <> input <> "\""
    error.DateTimeOffsetParseError(input, _) ->
      "Time out of bounds in \"" <> input <> "\""
  }
}

/// Decoder for exiftool datetime strings (format: "YYYY:MM:DD HH:MM:SS" or with timezone)
pub fn datetime_decoder() -> decode.Decoder(tempo.DateTime) {
  decode.string
  |> decode.then(fn(datetime_str) {
    // Handle different datetime formats from exiftool
    // Replace +00:00 with Z for better parsing compatibility
    let normalized_datetime = string.replace(datetime_str, "+00:00", "Z")

    let result = case
      string.contains(normalized_datetime, "+")
      || string.contains(normalized_datetime, "-")
      || string.contains(normalized_datetime, "Z")
    {
      True -> {
        // Has timezone - Format: "2025:07:09 20:31:55-05:00" or "2025:07:09 20:31:55Z"

        datetime.parse(
          normalized_datetime,
          tempo.Custom("YYYY:MM:DD HH:mm:ssZ"),
        )
      }
      False -> {
        // No timezone - assume UTC - Format: "2025:07:10 01:31:54"
        let with_utc = normalized_datetime <> "Z"
        datetime.parse(with_utc, tempo.Custom("YYYY:MM:DD HH:mm:ssZ"))
      }
    }

    case result {
      Ok(dt) -> decode.success(dt)
      Error(parse_error) ->
        decode.failure(
          datetime.literal("1970-01-01T00:01:01Z"),
          format_datetime_parse_error(parse_error),
        )
    }
  })
}

/// Decoder helper that wraps optional_field and returns an Option type
fn optional_field(
  field_name: String,
  decoder: decode.Decoder(a),
  next: fn(option.Option(a)) -> decode.Decoder(final),
) -> decode.Decoder(final) {
  decode.optional_field(
    field_name,
    option.None,
    decoder |> decode.map(option.Some),
    next,
  )
}

pub fn exif_data_decoder() -> decode.Decoder(ExifData) {
  // File information
  use source_file <- decode.field("SourceFile", decode.string)

  use file_name <- decode.field("FileName", decode.string)
  use directory <- decode.field("Directory", decode.string)
  use file_size <- decode.field("FileSize", file_size.decoder())
  use file_modify_date <- decode.field("FileModifyDate", datetime_decoder())
  use file_access_date <- decode.field("FileAccessDate", datetime_decoder())
  use file_inode_change_date <- decode.field(
    "FileInodeChangeDate",
    datetime_decoder(),
  )
  use file_permissions <- decode.field("FilePermissions", decode.string)
  use file_type <- decode.field("FileType", file_type.decoder())
  use file_type_extension <- decode.field("FileTypeExtension", decode.string)
  use mime_type <- decode.field("MIMEType", decode.string)

  // Media information - some fields may not exist for all file types
  use major_brand <- optional_field("MajorBrand", decode.string)
  use minor_version <- optional_field("MinorVersion", decode.string)
  use compatible_brands <- optional_field(
    "CompatibleBrands",
    decode.list(decode.string),
  )
  use media_data_size <- optional_field("MediaDataSize", decode.int)
  use media_data_offset <- optional_field("MediaDataOffset", decode.int)

  // Movie/Video information - optional for non-video files
  use movie_header_version <- optional_field("MovieHeaderVersion", decode.int)
  use create_date <- optional_field("CreateDate", datetime_decoder())
  use modify_date <- optional_field("ModifyDate", datetime_decoder())
  use time_scale <- optional_field("TimeScale", decode.int)
  use duration <- optional_field("Duration", decode.string)
  use preferred_rate <- optional_field(
    "PreferredRate",
    number_as_float_decoder(),
  )
  use preferred_volume <- optional_field("PreferredVolume", decode.string)
  use preview_time <- optional_field("PreviewTime", decode.string)
  use preview_duration <- optional_field("PreviewDuration", decode.string)
  use poster_time <- optional_field("PosterTime", decode.string)
  use selection_time <- optional_field("SelectionTime", decode.string)
  use selection_duration <- optional_field("SelectionDuration", decode.string)
  use current_time <- optional_field("CurrentTime", decode.string)
  use next_track_id <- optional_field("NextTrackID", decode.int)

  // Track information - optional for non-video files
  use track_header_version <- optional_field("TrackHeaderVersion", decode.int)
  use track_create_date <- optional_field("TrackCreateDate", datetime_decoder())
  use track_modify_date <- optional_field("TrackModifyDate", datetime_decoder())
  use track_id <- optional_field("TrackID", decode.int)
  use track_duration <- optional_field("TrackDuration", decode.string)
  use track_layer <- optional_field("TrackLayer", decode.int)
  use track_volume <- optional_field("TrackVolume", decode.string)

  // Image/Video dimensions
  use image_width <- optional_field("ImageWidth", decode.int)
  use image_height <- optional_field("ImageHeight", decode.int)
  use clean_aperture_dimensions <- optional_field(
    "CleanApertureDimensions",
    decode.string,
  )
  use production_aperture_dimensions <- optional_field(
    "ProductionApertureDimensions",
    decode.string,
  )
  use encoded_pixels_dimensions <- optional_field(
    "EncodedPixelsDimensions",
    decode.string,
  )

  // Graphics and compression - optional for non-video files
  use graphics_mode <- optional_field("GraphicsMode", decode.string)
  use op_color <- optional_field("OpColor", decode.string)
  use compressor_id <- optional_field("CompressorID", decode.string)
  use source_image_width <- optional_field("SourceImageWidth", decode.int)
  use source_image_height <- optional_field("SourceImageHeight", decode.int)
  use x_resolution <- optional_field("XResolution", decode.int)
  use y_resolution <- optional_field("YResolution", decode.int)
  use compressor_name <- optional_field("CompressorName", decode.string)
  use bit_depth <- optional_field("BitDepth", decode.int)
  use video_frame_rate <- optional_field(
    "VideoFrameRate",
    number_as_float_decoder(),
  )

  // Camera information - optional
  use lens_model <- optional_field("LensModel", decode.string)
  use lens_model_eng_us <- optional_field("LensModel-eng-US", decode.string)
  use focal_length_in_35mm_format <- optional_field(
    "FocalLengthIn35mmFormat",
    focal_length.decoder(),
  )
  use focal_length_in_35mm_format_eng_us <- optional_field(
    "FocalLengthIn35mmFormat-eng-US",
    decode.int,
  )

  // Audio information - optional for non-audio files
  use balance <- optional_field("Balance", decode.int)
  use audio_format <- optional_field("AudioFormat", decode.string)
  use audio_channels <- optional_field("AudioChannels", decode.int)
  use audio_bits_per_sample <- optional_field("AudioBitsPerSample", decode.int)
  use audio_sample_rate <- optional_field("AudioSampleRate", decode.int)
  use purchase_file_format <- optional_field(
    "PurchaseFileFormat",
    decode.string,
  )

  // Media metadata - optional
  use content_describes <- optional_field("ContentDescribes", decode.string)
  use matrix_structure <- optional_field("MatrixStructure", decode.string)
  use media_header_version <- optional_field("MediaHeaderVersion", decode.int)
  use media_create_date <- optional_field("MediaCreateDate", datetime_decoder())
  use media_modify_date <- optional_field("MediaModifyDate", datetime_decoder())
  use media_time_scale <- optional_field("MediaTimeScale", decode.int)
  use media_duration <- optional_field("MediaDuration", decode.string)
  use media_language_code <- optional_field("MediaLanguageCode", decode.string)

  // Handler information - optional
  use gen_media_version <- optional_field("GenMediaVersion", decode.int)
  use gen_flags <- optional_field("GenFlags", decode.string)
  use gen_graphics_mode <- optional_field("GenGraphicsMode", decode.string)
  use gen_op_color <- optional_field("GenOpColor", decode.string)
  use gen_balance <- optional_field("GenBalance", decode.int)
  use handler_class <- optional_field("HandlerClass", decode.string)
  use handler_vendor_id <- optional_field("HandlerVendorID", decode.string)
  use handler_description <- optional_field("HandlerDescription", decode.string)
  use handler_type <- optional_field("HandlerType", decode.string)
  use meta_format <- optional_field("MetaFormat", decode.string)

  // Device information - optional
  use make <- optional_field("Make", decode.string)
  use model <- optional_field("Model", decode.string)
  use software <- optional_field("Software", number_as_float_decoder())

  // Content metadata - optional
  use display_name <- optional_field("DisplayName", decode.string)
  use description <- optional_field("Description", decode.string)
  use creation_date <- optional_field("CreationDate", datetime_decoder())
  use keywords <- optional_field("Keywords", decode.string)

  // Calculated fields - optional
  use image_size <- optional_field("ImageSize", decode.string)
  use megapixels <- optional_field("Megapixels", number_as_float_decoder())
  use avg_bitrate <- optional_field("AvgBitrate", decode.string)
  use rotation <- optional_field("Rotation", decode.int)
  use lens_id <- optional_field("LensID", decode.string)

  // Tool information
  use exif_tool_version <- decode.field(
    "ExifToolVersion",
    number_as_float_decoder(),
  )
  use warning <- optional_field("Warning", decode.string)
  use full_frame_rate_playback_intent <- optional_field(
    "FullFrameRatePlaybackIntent",
    decode.int,
  )

  decode.success(ExifData(
    source_file: source_file,
    file_name: file_name,
    directory: directory,
    file_size: file_size,
    file_modify_date: file_modify_date,
    file_access_date: file_access_date,
    file_inode_change_date: file_inode_change_date,
    file_permissions: file_permissions,
    file_type: file_type,
    file_type_extension: file_type_extension,
    mime_type: mime_type,
    major_brand: major_brand,
    minor_version: minor_version,
    compatible_brands: compatible_brands,
    media_data_size: media_data_size,
    media_data_offset: media_data_offset,
    movie_header_version: movie_header_version,
    create_date: create_date,
    modify_date: modify_date,
    time_scale: time_scale,
    duration: duration,
    preferred_rate: preferred_rate,
    preferred_volume: preferred_volume,
    preview_time: preview_time,
    preview_duration: preview_duration,
    poster_time: poster_time,
    selection_time: selection_time,
    selection_duration: selection_duration,
    current_time: current_time,
    next_track_id: next_track_id,
    track_header_version: track_header_version,
    track_create_date: track_create_date,
    track_modify_date: track_modify_date,
    track_id: track_id,
    track_duration: track_duration,
    track_layer: track_layer,
    track_volume: track_volume,
    image_width: image_width,
    image_height: image_height,
    clean_aperture_dimensions: clean_aperture_dimensions,
    production_aperture_dimensions: production_aperture_dimensions,
    encoded_pixels_dimensions: encoded_pixels_dimensions,
    graphics_mode: graphics_mode,
    op_color: op_color,
    compressor_id: compressor_id,
    source_image_width: source_image_width,
    source_image_height: source_image_height,
    x_resolution: x_resolution,
    y_resolution: y_resolution,
    compressor_name: compressor_name,
    bit_depth: bit_depth,
    video_frame_rate: video_frame_rate,
    lens_model: lens_model,
    lens_model_eng_us: lens_model_eng_us,
    focal_length_in_35mm_format: focal_length_in_35mm_format,
    focal_length_in_35mm_format_eng_us: focal_length_in_35mm_format_eng_us,
    balance: balance,
    audio_format: audio_format,
    audio_channels: audio_channels,
    audio_bits_per_sample: audio_bits_per_sample,
    audio_sample_rate: audio_sample_rate,
    purchase_file_format: purchase_file_format,
    content_describes: content_describes,
    matrix_structure: matrix_structure,
    media_header_version: media_header_version,
    media_create_date: media_create_date,
    media_modify_date: media_modify_date,
    media_time_scale: media_time_scale,
    media_duration: media_duration,
    media_language_code: media_language_code,
    gen_media_version: gen_media_version,
    gen_flags: gen_flags,
    gen_graphics_mode: gen_graphics_mode,
    gen_op_color: gen_op_color,
    gen_balance: gen_balance,
    handler_class: handler_class,
    handler_vendor_id: handler_vendor_id,
    handler_description: handler_description,
    handler_type: handler_type,
    meta_format: meta_format,
    make: make,
    model: model,
    software: software,
    display_name: display_name,
    description: description,
    creation_date: creation_date,
    keywords: keywords,
    image_size: image_size,
    megapixels: megapixels,
    avg_bitrate: avg_bitrate,
    rotation: rotation,
    lens_id: lens_id,
    exif_tool_version: exif_tool_version,
    warning: warning,
    full_frame_rate_playback_intent: full_frame_rate_playback_intent,
  ))
}

pub fn get_media_file_metadata(file_path: String) -> Result(ExifData, Nil) {
  get_media_files_metadata(file_path)
  |> result.map(list.first)
  |> result.flatten
}

pub fn get_media_files_metadata(
  file_path: String,
) -> Result(List(ExifData), Nil) {
  shellout.command(run: "exiftool", with: ["-j", file_path], in: ".", opt: [])
  |> result.try(fn(output) {
    case json.parse(output, exiftool_json_decoder()) {
      Ok(data) -> Ok(data)
      Error(json_error) -> {
        case json_error {
          json.UnexpectedByte(byte) -> {
            io.println_error(
              "JSON parsing error: Unexpected byte '" <> byte <> "'",
            )
          }
          json.UnexpectedEndOfInput -> {
            io.println_error("JSON parsing error: Unexpected end of input")
          }
          json.UnexpectedSequence(str) -> {
            io.println_error("JSON decoding error: Failed to decode ExifData")
            io.println_error("Decoding errors: " <> string.inspect(str))
          }
          json.UnableToDecode(errors) -> {
            io.println_error("JSON decoding error: Unable to decode data")
            list.each(errors, fn(error) {
              let decode.DecodeError(expected, found, path) = error
              io.println_error(
                "  - Expected: "
                <> expected
                <> ", Found: "
                <> found
                <> " at path: "
                <> string.join(path, "."),
              )
            })
          }
        }
        Error(#(1, "Failed to parse JSON from exiftool"))
      }
    }
  })
  |> result.map_error(fn(error_data) {
    let #(code, message) = error_data
    io.println_error(message)
    shellout.exit(code)
  })
  |> result.replace_error(Nil)
}

/// Get the source_file from a Result(ExifData, e)
pub fn get_source_file(result: Result(ExifData, e)) -> String {
  case result {
    Ok(data) -> data.source_file
    Error(_) -> ""
  }
}

/// Get the file_name from a Result(ExifData, e)
pub fn get_file_name(result: Result(ExifData, e)) -> String {
  case result {
    Ok(data) -> data.file_name
    Error(_) -> ""
  }
}

/// Get the directory from a Result(ExifData, e)
pub fn get_directory(result: Result(ExifData, e)) -> String {
  case result {
    Ok(data) -> data.directory
    Error(_) -> ""
  }
}

/// Get the file_size from a Result(ExifData, e)
pub fn get_file_size(result: Result(ExifData, e)) -> file_size.FileSize {
  case result {
    Ok(data) -> data.file_size
    Error(_) -> file_size.UnknownFileSize
  }
}

/// Get the file_modify_date from a Result(ExifData, e)
pub fn get_file_modify_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> option.Some(data.file_modify_date)
    Error(_) -> option.None
  }
}

/// Get the file_access_date from a Result(ExifData, e)
pub fn get_file_access_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> option.Some(data.file_access_date)
    Error(_) -> option.None
  }
}

/// Get the file_inode_change_date from a Result(ExifData, e)
pub fn get_file_inode_change_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> option.Some(data.file_inode_change_date)
    Error(_) -> option.None
  }
}

/// Get the file_permissions from a Result(ExifData, e)
pub fn get_file_permissions(result: Result(ExifData, e)) -> String {
  case result {
    Ok(data) -> data.file_permissions
    Error(_) -> ""
  }
}

/// Get the file_type from a Result(ExifData, e)
pub fn get_file_type(result: Result(ExifData, e)) -> file_type.FileType {
  case result {
    Ok(data) -> data.file_type
    Error(_) -> file_type.from_string("")
  }
}

/// Get the file_type_extension from a Result(ExifData, e)
pub fn get_file_type_extension(result: Result(ExifData, e)) -> String {
  case result {
    Ok(data) -> data.file_type_extension
    Error(_) -> ""
  }
}

/// Get the mime_type from a Result(ExifData, e)
pub fn get_mime_type(result: Result(ExifData, e)) -> String {
  case result {
    Ok(data) -> data.mime_type
    Error(_) -> ""
  }
}

/// Get the major_brand from a Result(ExifData, e)
pub fn get_major_brand(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.major_brand
    Error(_) -> option.None
  }
}

/// Get the minor_version from a Result(ExifData, e)
pub fn get_minor_version(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.minor_version
    Error(_) -> option.None
  }
}

/// Get the compatible_brands from a Result(ExifData, e)
pub fn get_compatible_brands(
  result: Result(ExifData, e),
) -> option.Option(List(String)) {
  case result {
    Ok(data) -> data.compatible_brands
    Error(_) -> option.None
  }
}

/// Get the media_data_size from a Result(ExifData, e)
pub fn get_media_data_size(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.media_data_size
    Error(_) -> option.None
  }
}

/// Get the media_data_offset from a Result(ExifData, e)
pub fn get_media_data_offset(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.media_data_offset
    Error(_) -> option.None
  }
}

/// Get the movie_header_version from a Result(ExifData, e)
pub fn get_movie_header_version(
  result: Result(ExifData, e),
) -> option.Option(Int) {
  case result {
    Ok(data) -> data.movie_header_version
    Error(_) -> option.None
  }
}

/// Get the create_date from a Result(ExifData, e)
pub fn get_create_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> data.create_date
    Error(_) -> option.None
  }
}

/// Get the modify_date from a Result(ExifData, e)
pub fn get_modify_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> data.modify_date
    Error(_) -> option.None
  }
}

/// Get the time_scale from a Result(ExifData, e)
pub fn get_time_scale(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.time_scale
    Error(_) -> option.None
  }
}

/// Get the duration from a Result(ExifData, e)
pub fn get_duration(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.duration
    Error(_) -> option.None
  }
}

/// Get the preferred_rate from a Result(ExifData, e)
pub fn get_preferred_rate(result: Result(ExifData, e)) -> option.Option(Float) {
  case result {
    Ok(data) -> data.preferred_rate
    Error(_) -> option.None
  }
}

/// Get the preferred_volume from a Result(ExifData, e)
pub fn get_preferred_volume(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.preferred_volume
    Error(_) -> option.None
  }
}

/// Get the preview_time from a Result(ExifData, e)
pub fn get_preview_time(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.preview_time
    Error(_) -> option.None
  }
}

/// Get the preview_duration from a Result(ExifData, e)
pub fn get_preview_duration(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.preview_duration
    Error(_) -> option.None
  }
}

/// Get the poster_time from a Result(ExifData, e)
pub fn get_poster_time(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.poster_time
    Error(_) -> option.None
  }
}

/// Get the selection_time from a Result(ExifData, e)
pub fn get_selection_time(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.selection_time
    Error(_) -> option.None
  }
}

/// Get the selection_duration from a Result(ExifData, e)
pub fn get_selection_duration(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.selection_duration
    Error(_) -> option.None
  }
}

/// Get the current_time from a Result(ExifData, e)
pub fn get_current_time(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.current_time
    Error(_) -> option.None
  }
}

/// Get the next_track_id from a Result(ExifData, e)
pub fn get_next_track_id(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.next_track_id
    Error(_) -> option.None
  }
}

/// Get the track_header_version from a Result(ExifData, e)
pub fn get_track_header_version(
  result: Result(ExifData, e),
) -> option.Option(Int) {
  case result {
    Ok(data) -> data.track_header_version
    Error(_) -> option.None
  }
}

/// Get the track_create_date from a Result(ExifData, e)
pub fn get_track_create_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> data.track_create_date
    Error(_) -> option.None
  }
}

/// Get the track_modify_date from a Result(ExifData, e)
pub fn get_track_modify_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> data.track_modify_date
    Error(_) -> option.None
  }
}

/// Get the track_id from a Result(ExifData, e)
pub fn get_track_id(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.track_id
    Error(_) -> option.None
  }
}

/// Get the track_duration from a Result(ExifData, e)
pub fn get_track_duration(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.track_duration
    Error(_) -> option.None
  }
}

/// Get the track_layer from a Result(ExifData, e)
pub fn get_track_layer(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.track_layer
    Error(_) -> option.None
  }
}

/// Get the track_volume from a Result(ExifData, e)
pub fn get_track_volume(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.track_volume
    Error(_) -> option.None
  }
}

/// Get the image_width from a Result(ExifData, e)
pub fn get_image_width(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.image_width
    Error(_) -> option.None
  }
}

/// Get the image_height from a Result(ExifData, e)
pub fn get_image_height(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.image_height
    Error(_) -> option.None
  }
}

/// Get the clean_aperture_dimensions from a Result(ExifData, e)
pub fn get_clean_aperture_dimensions(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.clean_aperture_dimensions
    Error(_) -> option.None
  }
}

/// Get the production_aperture_dimensions from a Result(ExifData, e)
pub fn get_production_aperture_dimensions(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.production_aperture_dimensions
    Error(_) -> option.None
  }
}

/// Get the encoded_pixels_dimensions from a Result(ExifData, e)
pub fn get_encoded_pixels_dimensions(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.encoded_pixels_dimensions
    Error(_) -> option.None
  }
}

/// Get the graphics_mode from a Result(ExifData, e)
pub fn get_graphics_mode(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.graphics_mode
    Error(_) -> option.None
  }
}

/// Get the op_color from a Result(ExifData, e)
pub fn get_op_color(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.op_color
    Error(_) -> option.None
  }
}

/// Get the compressor_id from a Result(ExifData, e)
pub fn get_compressor_id(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.compressor_id
    Error(_) -> option.None
  }
}

/// Get the source_image_width from a Result(ExifData, e)
pub fn get_source_image_width(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.source_image_width
    Error(_) -> option.None
  }
}

/// Get the source_image_height from a Result(ExifData, e)
pub fn get_source_image_height(
  result: Result(ExifData, e),
) -> option.Option(Int) {
  case result {
    Ok(data) -> data.source_image_height
    Error(_) -> option.None
  }
}

/// Get the x_resolution from a Result(ExifData, e)
pub fn get_x_resolution(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.x_resolution
    Error(_) -> option.None
  }
}

/// Get the y_resolution from a Result(ExifData, e)
pub fn get_y_resolution(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.y_resolution
    Error(_) -> option.None
  }
}

/// Get the compressor_name from a Result(ExifData, e)
pub fn get_compressor_name(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.compressor_name
    Error(_) -> option.None
  }
}

/// Get the bit_depth from a Result(ExifData, e)
pub fn get_bit_depth(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.bit_depth
    Error(_) -> option.None
  }
}

/// Get the video_frame_rate from a Result(ExifData, e)
pub fn get_video_frame_rate(result: Result(ExifData, e)) -> option.Option(Float) {
  case result {
    Ok(data) -> data.video_frame_rate
    Error(_) -> option.None
  }
}

/// Get the lens_model from a Result(ExifData, e)
pub fn get_lens_model(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.lens_model
    Error(_) -> option.None
  }
}

/// Get the lens_model_eng_us from a Result(ExifData, e)
pub fn get_lens_model_eng_us(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.lens_model_eng_us
    Error(_) -> option.None
  }
}

/// Get the focal_length_in_35mm_format from a Result(ExifData, e)
pub fn get_focal_length_in_35mm_format(
  result: Result(ExifData, e),
) -> option.Option(focal_length.FocalLength) {
  case result {
    Ok(data) -> data.focal_length_in_35mm_format
    Error(_) -> option.None
  }
}

/// Get the focal_length_in_35mm_format_eng_us from a Result(ExifData, e)
pub fn get_focal_length_in_35mm_format_eng_us(
  result: Result(ExifData, e),
) -> option.Option(Int) {
  case result {
    Ok(data) -> data.focal_length_in_35mm_format_eng_us
    Error(_) -> option.None
  }
}

/// Get the balance from a Result(ExifData, e)
pub fn get_balance(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.balance
    Error(_) -> option.None
  }
}

/// Get the audio_format from a Result(ExifData, e)
pub fn get_audio_format(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.audio_format
    Error(_) -> option.None
  }
}

/// Get the audio_channels from a Result(ExifData, e)
pub fn get_audio_channels(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.audio_channels
    Error(_) -> option.None
  }
}

/// Get the audio_bits_per_sample from a Result(ExifData, e)
pub fn get_audio_bits_per_sample(
  result: Result(ExifData, e),
) -> option.Option(Int) {
  case result {
    Ok(data) -> data.audio_bits_per_sample
    Error(_) -> option.None
  }
}

/// Get the audio_sample_rate from a Result(ExifData, e)
pub fn get_audio_sample_rate(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.audio_sample_rate
    Error(_) -> option.None
  }
}

/// Get the purchase_file_format from a Result(ExifData, e)
pub fn get_purchase_file_format(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.purchase_file_format
    Error(_) -> option.None
  }
}

/// Get the content_describes from a Result(ExifData, e)
pub fn get_content_describes(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.content_describes
    Error(_) -> option.None
  }
}

/// Get the matrix_structure from a Result(ExifData, e)
pub fn get_matrix_structure(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.matrix_structure
    Error(_) -> option.None
  }
}

/// Get the media_header_version from a Result(ExifData, e)
pub fn get_media_header_version(
  result: Result(ExifData, e),
) -> option.Option(Int) {
  case result {
    Ok(data) -> data.media_header_version
    Error(_) -> option.None
  }
}

/// Get the media_create_date from a Result(ExifData, e)
pub fn get_media_create_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> data.media_create_date
    Error(_) -> option.None
  }
}

/// Get the media_modify_date from a Result(ExifData, e)
pub fn get_media_modify_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> data.media_modify_date
    Error(_) -> option.None
  }
}

/// Get the media_time_scale from a Result(ExifData, e)
pub fn get_media_time_scale(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.media_time_scale
    Error(_) -> option.None
  }
}

/// Get the media_duration from a Result(ExifData, e)
pub fn get_media_duration(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.media_duration
    Error(_) -> option.None
  }
}

/// Get the media_language_code from a Result(ExifData, e)
pub fn get_media_language_code(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.media_language_code
    Error(_) -> option.None
  }
}

/// Get the gen_media_version from a Result(ExifData, e)
pub fn get_gen_media_version(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.gen_media_version
    Error(_) -> option.None
  }
}

/// Get the gen_flags from a Result(ExifData, e)
pub fn get_gen_flags(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.gen_flags
    Error(_) -> option.None
  }
}

/// Get the gen_graphics_mode from a Result(ExifData, e)
pub fn get_gen_graphics_mode(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.gen_graphics_mode
    Error(_) -> option.None
  }
}

/// Get the gen_op_color from a Result(ExifData, e)
pub fn get_gen_op_color(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.gen_op_color
    Error(_) -> option.None
  }
}

/// Get the gen_balance from a Result(ExifData, e)
pub fn get_gen_balance(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.gen_balance
    Error(_) -> option.None
  }
}

/// Get the handler_class from a Result(ExifData, e)
pub fn get_handler_class(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.handler_class
    Error(_) -> option.None
  }
}

/// Get the handler_vendor_id from a Result(ExifData, e)
pub fn get_handler_vendor_id(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.handler_vendor_id
    Error(_) -> option.None
  }
}

/// Get the handler_description from a Result(ExifData, e)
pub fn get_handler_description(
  result: Result(ExifData, e),
) -> option.Option(String) {
  case result {
    Ok(data) -> data.handler_description
    Error(_) -> option.None
  }
}

/// Get the handler_type from a Result(ExifData, e)
pub fn get_handler_type(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.handler_type
    Error(_) -> option.None
  }
}

/// Get the meta_format from a Result(ExifData, e)
pub fn get_meta_format(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.meta_format
    Error(_) -> option.None
  }
}

/// Get the make from a Result(ExifData, e)
pub fn get_make(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.make
    Error(_) -> option.None
  }
}

/// Get the model from a Result(ExifData, e)
pub fn get_model(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.model
    Error(_) -> option.None
  }
}

/// Get the software from a Result(ExifData, e)
pub fn get_software(result: Result(ExifData, e)) -> option.Option(Float) {
  case result {
    Ok(data) -> data.software
    Error(_) -> option.None
  }
}

/// Get the display_name from a Result(ExifData, e)
pub fn get_display_name(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.display_name
    Error(_) -> option.None
  }
}

/// Get the description from a Result(ExifData, e)
pub fn get_description(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.description
    Error(_) -> option.None
  }
}

/// Get the creation_date from a Result(ExifData, e)
pub fn get_creation_date(
  result: Result(ExifData, e),
) -> option.Option(tempo.DateTime) {
  case result {
    Ok(data) -> data.creation_date
    Error(_) -> option.None
  }
}

/// Get the keywords from a Result(ExifData, e)
pub fn get_keywords(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.keywords
    Error(_) -> option.None
  }
}

/// Get the image_size from a Result(ExifData, e)
pub fn get_image_size(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.image_size
    Error(_) -> option.None
  }
}

/// Get the megapixels from a Result(ExifData, e)
pub fn get_megapixels(result: Result(ExifData, e)) -> option.Option(Float) {
  case result {
    Ok(data) -> data.megapixels
    Error(_) -> option.None
  }
}

/// Get the avg_bitrate from a Result(ExifData, e)
pub fn get_avg_bitrate(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.avg_bitrate
    Error(_) -> option.None
  }
}

/// Get the rotation from a Result(ExifData, e)
pub fn get_rotation(result: Result(ExifData, e)) -> option.Option(Int) {
  case result {
    Ok(data) -> data.rotation
    Error(_) -> option.None
  }
}

/// Get the lens_id from a Result(ExifData, e)
pub fn get_lens_id(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.lens_id
    Error(_) -> option.None
  }
}

/// Get the exif_tool_version from a Result(ExifData, e)
pub fn get_exif_tool_version(
  result: Result(ExifData, e),
) -> option.Option(Float) {
  case result {
    Ok(data) -> option.Some(data.exif_tool_version)
    Error(_) -> option.None
  }
}

/// Get the warning from a Result(ExifData, e)
pub fn get_warning(result: Result(ExifData, e)) -> option.Option(String) {
  case result {
    Ok(data) -> data.warning
    Error(_) -> option.None
  }
}

/// Get the full_frame_rate_playback_intent from a Result(ExifData, e)
pub fn get_full_frame_rate_playback_intent(
  result: Result(ExifData, e),
) -> option.Option(Int) {
  case result {
    Ok(data) -> data.full_frame_rate_playback_intent
    Error(_) -> option.None
  }
}
