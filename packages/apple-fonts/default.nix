{
  lib,
  stdenv,
  fetchurl,
  unzip,
  p7zip,
  cpio,
}:
stdenv.mkDerivation rec {
  pname = "Apple-Fonts";
  version = "1";

  pro = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    sha256 = "sha256-loqzuLH5LC2K9h6waA9cIiTE541ZuYa/AEUCp/wBKRg=";
  };

  compact = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
    sha256 = "sha256-wdDjROut1m62LwP4I3hMzknxeH9WVj+wmPygH8VUE1w=";
  };

  mono = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
    sha256 = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
  };

  ny = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
    sha256 = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
  };

  nativeBuildInputs = [
    p7zip
    cpio
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/fontfiles

    extract_font() {
      archive="$1"
      workdir=$(mktemp -d)

      7z x "$archive" -o"$workdir/dmg" >/dev/null
      payload=$(find "$workdir/dmg" -type f -name Payload -print -quit)

      if [ -z "$payload" ]; then
        package=$(find "$workdir/dmg" -type f -name '*.pkg' -print -quit)
        if [ -n "$package" ]; then
          7z x "$package" -o"$workdir/pkg" >/dev/null
          payload=$(find "$workdir/pkg" -type f -name Payload -print -quit)
        fi
      fi

      if [ -z "$payload" ]; then
        payload=$(find "$workdir/dmg" "$workdir/pkg" -type f -name 'Payload~' -print -quit 2>/dev/null || true)
      fi

      if [ -z "$payload" ]; then
        echo "Could not find a Payload archive in $archive" >&2
        find "$workdir/dmg" -maxdepth 3 -type f -print >&2
        exit 1
      fi

      mkdir -p "$workdir/payload"

      if [ "$(basename "$payload")" = 'Payload~' ]; then
        (cd "$workdir/payload" && cpio -idm --quiet < "$payload")
      else
        7z x "$payload" -o"$workdir/unpacked-payload" >/dev/null
        cpio_payload=$(find "$workdir/unpacked-payload" -type f -name 'Payload~' -print -quit)

        if [ -n "$cpio_payload" ]; then
          (cd "$workdir/payload" && cpio -idm --quiet < "$cpio_payload")
        else
          cp -R "$workdir/unpacked-payload/." "$workdir/payload/"
        fi
      fi

      find "$workdir/payload/Library/Fonts" -type f -exec cp {} "$out/fontfiles/" \;
      rm -rf "$workdir"
    }

    extract_font ${pro}
    extract_font ${mono}
    extract_font ${compact}
    extract_font ${ny}

    mkdir -p $out/share/fonts/opentype/${pname}
    mkdir -p $out/share/fonts/truetype/${pname}
    mv $out/fontfiles/*.otf $out/share/fonts/opentype/${pname}/ 2>/dev/null || true
    mv $out/fontfiles/*.ttf $out/share/fonts/truetype/${pname}/ 2>/dev/null || true
    rm -rf $out/fontfiles
  '';

  meta = {
    description = "Apple San Francisco, New York fonts";
    homepage = "https://developer.apple.com/fonts/";
    license = lib.licenses.unfree;
  };
}
