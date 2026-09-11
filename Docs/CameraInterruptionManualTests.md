# Camera interruption manual tests

Run these checks on physical devices because the Simulator cannot reproduce all
AVFoundation interruptions.

## Camera used by another app

1. Open the MediaPicker camera.
2. Start a video call or another camera session.
3. Confirm that MediaPicker disables its camera controls.
4. End the other session and confirm that MediaPicker becomes ready again.

## iPad Split View and Stage Manager

1. Open MediaPicker on a supported physical iPad.
2. Place another app beside it using Split View or Stage Manager.
3. Confirm that the preview and controls remain active.
4. On unsupported hardware, confirm that MediaPicker enters its safe interrupted
   state instead of accepting invalid commands.

MediaPicker enables multitasking camera access whenever AVFoundation reports it
as supported. The host app remains responsible for capabilities or entitlements
required by its iOS version and use case.

## Media-services reset

1. Keep the preview open while reproducing an AVFoundation media-services reset.
2. Confirm that the session rebuilds with the same camera position.
3. Confirm that only one automatic recovery is attempted.
4. Reproduce another reset and confirm that an error is reported without a loop.

## Teardown

1. Open and close MediaPicker repeatedly.
2. Confirm that reopening does not register duplicate notification observers.
