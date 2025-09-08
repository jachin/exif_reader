import gleam/dynamic/decode
import gleam/string

pub type MimeType {
  ImageMime(subtype: String)
  VideoMime(subtype: String)
  AudioMime(subtype: String)
  DocumentMime(subtype: String)
  ArchiveMime(subtype: String)
  UnknownMime(mime_string: String)
}

pub type FileType {
  Image(format: ImageFormat, file_type_extension: String, mime_type: MimeType)
  Video(format: VideoFormat, file_type_extension: String, mime_type: MimeType)
  Audio(format: AudioFormat, file_type_extension: String, mime_type: MimeType)
  Document(
    format: DocumentFormat,
    file_type_extension: String,
    mime_type: MimeType,
  )
  Archive(
    format: ArchiveFormat,
    file_type_extension: String,
    mime_type: MimeType,
  )
  Unknown(raw_type: String, file_type_extension: String, mime_type: MimeType)
}

pub type ImageFormat {
  JPEG
  PNG
  GIF
  BMP
  TIFF
  WEBP
  HEIC
  SVG
  RAW
  PSD
  OtherImage(format: String)
}

pub type VideoFormat {
  MP4
  MOV
  AVI
  MKV
  WEBM
  FLV
  WMV
  M4V
  OtherVideo(format: String)
}

pub type AudioFormat {
  MP3
  WAV
  FLAC
  AAC
  OGG
  M4A
  WMA
  OtherAudio(format: String)
}

pub type DocumentFormat {
  PDF
  DOC
  DOCX
  TXT
  RTF
  ODT
  OtherDocument(format: String)
}

pub type ArchiveFormat {
  ZIP
  RAR
  SevenZ
  TAR
  GZ
  BZ2
  OtherArchive(format: String)
}

pub fn parse_mime_type(mime_string: String) -> MimeType {
  case string.split(mime_string, "/") {
    ["image", subtype] -> ImageMime(subtype)
    ["video", subtype] -> VideoMime(subtype)
    ["audio", subtype] -> AudioMime(subtype)
    ["application", "pdf"] -> DocumentMime("pdf")
    ["application", "msword"] -> DocumentMime("msword")
    [
      "application",
      "vnd.openxmlformats-officedocument.wordprocessingml.document",
    ] ->
      DocumentMime(
        "vnd.openxmlformats-officedocument.wordprocessingml.document",
      )
    ["application", "rtf"] -> DocumentMime("rtf")
    ["application", "vnd.oasis.opendocument.text"] ->
      DocumentMime("vnd.oasis.opendocument.text")
    ["application", "zip"] -> ArchiveMime("zip")
    ["application", "vnd.rar"] -> ArchiveMime("vnd.rar")
    ["application", "x-7z-compressed"] -> ArchiveMime("x-7z-compressed")
    ["application", "x-tar"] -> ArchiveMime("x-tar")
    ["application", "gzip"] -> ArchiveMime("gzip")
    ["application", "x-bzip2"] -> ArchiveMime("x-bzip2")
    ["text", subtype] -> DocumentMime(subtype)
    _ -> UnknownMime(mime_string)
  }
}

pub fn get_file_extension(file_type_str: String) -> String {
  let normalized = string.lowercase(file_type_str)
  case normalized {
    "jpeg" | "jpg" -> "jpg"
    "png" -> "png"
    "gif" -> "gif"
    "bmp" -> "bmp"
    "tiff" | "tif" -> "tiff"
    "webp" -> "webp"
    "heic" | "heif" -> "heic"
    "svg" -> "svg"
    "raw" | "cr2" | "nef" | "arw" | "dng" -> "raw"
    "psd" -> "psd"
    "mp4" -> "mp4"
    "mov" -> "mov"
    "avi" -> "avi"
    "mkv" -> "mkv"
    "webm" -> "webm"
    "flv" -> "flv"
    "wmv" -> "wmv"
    "m4v" -> "m4v"
    "mp3" -> "mp3"
    "wav" -> "wav"
    "flac" -> "flac"
    "aac" -> "aac"
    "ogg" -> "ogg"
    "m4a" -> "m4a"
    "wma" -> "wma"
    "pdf" -> "pdf"
    "doc" -> "doc"
    "docx" -> "docx"
    "txt" -> "txt"
    "rtf" -> "rtf"
    "odt" -> "odt"
    "zip" -> "zip"
    "rar" -> "rar"
    "7z" -> "7z"
    "tar" -> "tar"
    "gz" -> "gz"
    "bz2" -> "bz2"
    _ -> normalized
  }
}

pub fn get_mime_type(file_type_str: String) -> String {
  let normalized = string.uppercase(file_type_str)
  case normalized {
    "JPEG" | "JPG" -> "image/jpeg"
    "PNG" -> "image/png"
    "GIF" -> "image/gif"
    "BMP" -> "image/bmp"
    "TIFF" | "TIF" -> "image/tiff"
    "WEBP" -> "image/webp"
    "HEIC" | "HEIF" -> "image/heic"
    "SVG" -> "image/svg+xml"
    "RAW" | "CR2" | "NEF" | "ARW" | "DNG" -> "image/x-raw"
    "PSD" -> "image/vnd.adobe.photoshop"
    "MP4" -> "video/mp4"
    "MOV" -> "video/quicktime"
    "AVI" -> "video/x-msvideo"
    "MKV" -> "video/x-matroska"
    "WEBM" -> "video/webm"
    "FLV" -> "video/x-flv"
    "WMV" -> "video/x-ms-wmv"
    "M4V" -> "video/x-m4v"
    "MP3" -> "audio/mpeg"
    "WAV" -> "audio/wav"
    "FLAC" -> "audio/flac"
    "AAC" -> "audio/aac"
    "OGG" -> "audio/ogg"
    "M4A" -> "audio/x-m4a"
    "WMA" -> "audio/x-ms-wma"
    "PDF" -> "application/pdf"
    "DOC" -> "application/msword"
    "DOCX" ->
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    "TXT" -> "text/plain"
    "RTF" -> "application/rtf"
    "ODT" -> "application/vnd.oasis.opendocument.text"
    "ZIP" -> "application/zip"
    "RAR" -> "application/vnd.rar"
    "7Z" -> "application/x-7z-compressed"
    "TAR" -> "application/x-tar"
    "GZ" -> "application/gzip"
    "BZ2" -> "application/x-bzip2"
    _ -> "application/octet-stream"
  }
}

pub fn from_string(file_type_str: String) -> FileType {
  let normalized = string.uppercase(file_type_str)
  let extension = get_file_extension(file_type_str)
  let mime_string = get_mime_type(file_type_str)
  let mime_type = parse_mime_type(mime_string)

  case normalized {
    "JPEG" | "JPG" -> Image(JPEG, extension, mime_type)
    "PNG" -> Image(PNG, extension, mime_type)
    "GIF" -> Image(GIF, extension, mime_type)
    "BMP" -> Image(BMP, extension, mime_type)
    "TIFF" | "TIF" -> Image(TIFF, extension, mime_type)
    "WEBP" -> Image(WEBP, extension, mime_type)
    "HEIC" | "HEIF" -> Image(HEIC, extension, mime_type)
    "SVG" -> Image(SVG, extension, mime_type)
    "RAW" | "CR2" | "NEF" | "ARW" | "DNG" -> Image(RAW, extension, mime_type)
    "PSD" -> Image(PSD, extension, mime_type)

    "MP4" -> Video(MP4, extension, mime_type)
    "MOV" -> Video(MOV, extension, mime_type)
    "AVI" -> Video(AVI, extension, mime_type)
    "MKV" -> Video(MKV, extension, mime_type)
    "WEBM" -> Video(WEBM, extension, mime_type)
    "FLV" -> Video(FLV, extension, mime_type)
    "WMV" -> Video(WMV, extension, mime_type)
    "M4V" -> Video(M4V, extension, mime_type)

    "MP3" -> Audio(MP3, extension, mime_type)
    "WAV" -> Audio(WAV, extension, mime_type)
    "FLAC" -> Audio(FLAC, extension, mime_type)
    "AAC" -> Audio(AAC, extension, mime_type)
    "OGG" -> Audio(OGG, extension, mime_type)
    "M4A" -> Audio(M4A, extension, mime_type)
    "WMA" -> Audio(WMA, extension, mime_type)

    "PDF" -> Document(PDF, extension, mime_type)
    "DOC" -> Document(DOC, extension, mime_type)
    "DOCX" -> Document(DOCX, extension, mime_type)
    "TXT" -> Document(TXT, extension, mime_type)
    "RTF" -> Document(RTF, extension, mime_type)
    "ODT" -> Document(ODT, extension, mime_type)

    "ZIP" -> Archive(ZIP, extension, mime_type)
    "RAR" -> Archive(RAR, extension, mime_type)
    "7Z" -> Archive(SevenZ, extension, mime_type)
    "TAR" -> Archive(TAR, extension, mime_type)
    "GZ" -> Archive(GZ, extension, mime_type)
    "BZ2" -> Archive(BZ2, extension, mime_type)

    _ -> Unknown(file_type_str, extension, mime_type)
  }
}

pub fn decoder() -> decode.Decoder(FileType) {
  decode.string
  |> decode.map(from_string)
}

pub fn object_decoder() -> decode.Decoder(FileType) {
  use file_type_str <- decode.field("file_type", decode.string)
  use extension <- decode.field("file_type_extension", decode.string)
  use mime_string <- decode.field("mime_type", decode.string)
  decode.success(construct_file_type(file_type_str, extension, mime_string))
}

pub fn construct_file_type(
  file_type_str: String,
  extension: String,
  mime_string: String,
) -> FileType {
  let normalized = string.uppercase(file_type_str)
  let mime_type = parse_mime_type(mime_string)

  case normalized {
    "JPEG" | "JPG" -> Image(JPEG, extension, mime_type)
    "PNG" -> Image(PNG, extension, mime_type)
    "GIF" -> Image(GIF, extension, mime_type)
    "BMP" -> Image(BMP, extension, mime_type)
    "TIFF" | "TIF" -> Image(TIFF, extension, mime_type)
    "WEBP" -> Image(WEBP, extension, mime_type)
    "HEIC" | "HEIF" -> Image(HEIC, extension, mime_type)
    "SVG" -> Image(SVG, extension, mime_type)
    "RAW" | "CR2" | "NEF" | "ARW" | "DNG" -> Image(RAW, extension, mime_type)
    "PSD" -> Image(PSD, extension, mime_type)

    "MP4" -> Video(MP4, extension, mime_type)
    "MOV" -> Video(MOV, extension, mime_type)
    "AVI" -> Video(AVI, extension, mime_type)
    "MKV" -> Video(MKV, extension, mime_type)
    "WEBM" -> Video(WEBM, extension, mime_type)
    "FLV" -> Video(FLV, extension, mime_type)
    "WMV" -> Video(WMV, extension, mime_type)
    "M4V" -> Video(M4V, extension, mime_type)

    "MP3" -> Audio(MP3, extension, mime_type)
    "WAV" -> Audio(WAV, extension, mime_type)
    "FLAC" -> Audio(FLAC, extension, mime_type)
    "AAC" -> Audio(AAC, extension, mime_type)
    "OGG" -> Audio(OGG, extension, mime_type)
    "M4A" -> Audio(M4A, extension, mime_type)
    "WMA" -> Audio(WMA, extension, mime_type)

    "PDF" -> Document(PDF, extension, mime_type)
    "DOC" -> Document(DOC, extension, mime_type)
    "DOCX" -> Document(DOCX, extension, mime_type)
    "TXT" -> Document(TXT, extension, mime_type)
    "RTF" -> Document(RTF, extension, mime_type)
    "ODT" -> Document(ODT, extension, mime_type)

    "ZIP" -> Archive(ZIP, extension, mime_type)
    "RAR" -> Archive(RAR, extension, mime_type)
    "7Z" -> Archive(SevenZ, extension, mime_type)
    "TAR" -> Archive(TAR, extension, mime_type)
    "GZ" -> Archive(GZ, extension, mime_type)
    "BZ2" -> Archive(BZ2, extension, mime_type)

    _ -> Unknown(file_type_str, extension, mime_type)
  }
}

pub fn to_string(file_type: FileType) -> String {
  case file_type {
    Image(format, _, _) -> image_format_to_string(format)
    Video(format, _, _) -> video_format_to_string(format)
    Audio(format, _, _) -> audio_format_to_string(format)
    Document(format, _, _) -> document_format_to_string(format)
    Archive(format, _, _) -> archive_format_to_string(format)
    Unknown(raw_type, _, _) -> raw_type
  }
}

pub fn get_extension(file_type: FileType) -> String {
  case file_type {
    Image(_, extension, _) -> extension
    Video(_, extension, _) -> extension
    Audio(_, extension, _) -> extension
    Document(_, extension, _) -> extension
    Archive(_, extension, _) -> extension
    Unknown(_, extension, _) -> extension
  }
}

pub fn get_mime(file_type: FileType) -> MimeType {
  case file_type {
    Image(_, _, mime_type) -> mime_type
    Video(_, _, mime_type) -> mime_type
    Audio(_, _, mime_type) -> mime_type
    Document(_, _, mime_type) -> mime_type
    Archive(_, _, mime_type) -> mime_type
    Unknown(_, _, mime_type) -> mime_type
  }
}

pub fn mime_to_string(mime_type: MimeType) -> String {
  case mime_type {
    ImageMime(subtype) -> "image/" <> subtype
    VideoMime(subtype) -> "video/" <> subtype
    AudioMime(subtype) -> "audio/" <> subtype
    DocumentMime(subtype) ->
      case subtype {
        "plain" -> "text/plain"
        _ -> "application/" <> subtype
      }
    ArchiveMime(subtype) -> "application/" <> subtype
    UnknownMime(mime_string) -> mime_string
  }
}

fn image_format_to_string(format: ImageFormat) -> String {
  case format {
    JPEG -> "JPEG"
    PNG -> "PNG"
    GIF -> "GIF"
    BMP -> "BMP"
    TIFF -> "TIFF"
    WEBP -> "WEBP"
    HEIC -> "HEIC"
    SVG -> "SVG"
    RAW -> "RAW"
    PSD -> "PSD"
    OtherImage(format) -> format
  }
}

fn video_format_to_string(format: VideoFormat) -> String {
  case format {
    MP4 -> "MP4"
    MOV -> "MOV"
    AVI -> "AVI"
    MKV -> "MKV"
    WEBM -> "WEBM"
    FLV -> "FLV"
    WMV -> "WMV"
    M4V -> "M4V"
    OtherVideo(format) -> format
  }
}

fn audio_format_to_string(format: AudioFormat) -> String {
  case format {
    MP3 -> "MP3"
    WAV -> "WAV"
    FLAC -> "FLAC"
    AAC -> "AAC"
    OGG -> "OGG"
    M4A -> "M4A"
    WMA -> "WMA"
    OtherAudio(format) -> format
  }
}

fn document_format_to_string(format: DocumentFormat) -> String {
  case format {
    PDF -> "PDF"
    DOC -> "DOC"
    DOCX -> "DOCX"
    TXT -> "TXT"
    RTF -> "RTF"
    ODT -> "ODT"
    OtherDocument(format) -> format
  }
}

fn archive_format_to_string(format: ArchiveFormat) -> String {
  case format {
    ZIP -> "ZIP"
    RAR -> "RAR"
    SevenZ -> "7Z"
    TAR -> "TAR"
    GZ -> "GZ"
    BZ2 -> "BZ2"
    OtherArchive(format) -> format
  }
}
