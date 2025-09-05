# exif_reader

This is a library that calls the [exif_tool](https://exiftool.org) command line tool and gets the EXIF metadata and brings it into Gleam with some nice types.

You need to have the exif_tool installed already and somewhere the [shellout](https://github.com/tynanbe/shellout) library can find it.

Someday it would be great if this library could just parse media files directly, but for now this solves my needs.

## Running via CLI

You _can_ run it as a cli program, although, there's probably not many good reasons to do that.

```sh
gleam run <media-file-path>
```

## Using it in an Application

```sh
gleam add exif_reader@1
```
```gleam
import exif_reader

pub fn main() -> Nil {
  let file_path = "picture.jpg"
  echo exif_reader.get_media_file_metadata(file_path)
    |> exif_reader.get_description
}
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
