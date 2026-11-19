#!/usr/bin/env bash
# Convert every PDF figure in static/images/ to a high-resolution PNG next to it.
# Uses macOS's built-in PDFKit/AppKit (via osascript), so nothing needs installing.
#
# Usage:  bash scripts/pdf_to_png.sh           # convert new or changed PDFs only
#         bash scripts/pdf_to_png.sh --force   # regenerate every PNG
#         SCALE=6 bash scripts/pdf_to_png.sh   # render larger (default 4x)

set -euo pipefail

cd "$(dirname "$0")/../static/images"
SCALE="${SCALE:-4}"
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

shopt -s nullglob
pdfs=(*.pdf)
if (( ${#pdfs[@]} == 0 )); then
  echo "No PDFs found in static/images/"
  exit 0
fi

for pdf in "${pdfs[@]}"; do
  png="${pdf%.pdf}.png"
  if (( FORCE == 0 )) && [[ -f "$png" && "$png" -nt "$pdf" ]]; then
    echo "skip     $png (up to date)"
    continue
  fi

  osascript -l JavaScript - "$PWD/$pdf" "$PWD/$png" "$SCALE" <<'JXA'
ObjC.import('AppKit');
function run(argv) {
  var src = argv[0], out = argv[1], scale = parseFloat(argv[2]);
  var rep = $.NSPDFImageRep.imageRepWithData($.NSData.dataWithContentsOfFile(src));
  if (rep.isNil()) throw new Error('Could not read ' + src);
  rep.currentPage = 0;
  var W = Math.round(rep.bounds.size.width * scale);
  var H = Math.round(rep.bounds.size.height * scale);

  var bmp = $.NSBitmapImageRep.alloc
    .initWithBitmapDataPlanesPixelsWidePixelsHighBitsPerSampleSamplesPerPixelHasAlphaIsPlanarColorSpaceNameBytesPerRowBitsPerPixel(
      null, W, H, 8, 4, true, false, $.NSDeviceRGBColorSpace, 0, 0);
  var ctx = $.NSGraphicsContext.graphicsContextWithBitmapImageRep(bmp);
  // (JXA calls zero-argument Objective-C methods on plain property access)
  $.NSGraphicsContext.saveGraphicsState;
  $.NSGraphicsContext.setCurrentContext(ctx);
  $.NSColor.whiteColor.setFill;
  $.NSRectFill($.NSMakeRect(0, 0, W, H));
  rep.drawInRect($.NSMakeRect(0, 0, W, H));
  ctx.flushGraphics;
  $.NSGraphicsContext.restoreGraphicsState;

  var data = bmp.representationUsingTypeProperties($.NSBitmapImageFileTypePNG, $());
  if (!data.writeToFileAtomically(out, true)) throw new Error('Could not write ' + out);
  return 'wrote    ' + out.split('/').pop() + ' (' + W + 'x' + H + ')';
}
JXA
done
