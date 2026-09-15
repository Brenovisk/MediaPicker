# Photo Orientation Manual Tests

Use a physical iPhone or iPad because Simulator camera input cannot validate
captured orientation and mirroring.

## Expected policy

- Back-camera photos are not mirrored.
- Front-camera photos are mirrored to match the live preview.
- The saved JPEG or PNG follows the interface orientation at capture time.

## Test matrix

Run every case with both JPEG and PNG output.

| Camera | Interface orientation | Expected result |
| --- | --- | --- |
| Back | Portrait | Upright and not mirrored |
| Back | Portrait upside down | Upright relative to the interface and not mirrored |
| Back | Landscape left | Upright relative to the interface and not mirrored |
| Back | Landscape right | Upright relative to the interface and not mirrored |
| Front | Portrait | Upright and mirrored like the preview |
| Front | Portrait upside down | Upright relative to the interface and mirrored |
| Front | Landscape left | Upright relative to the interface and mirrored |
| Front | Landscape right | Upright relative to the interface and mirrored |

For each case, rotate the device before tapping capture, open the returned file,
and compare a readable object or text in the saved image with the live preview.
Also rotate immediately before capture to confirm that the latest angle is used.
