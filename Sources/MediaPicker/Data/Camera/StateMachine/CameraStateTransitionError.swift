/** Describes an event rejected because it is incompatible with the current state. */
struct CameraStateTransitionError: Error, Sendable, Equatable {

    let state: CameraState
    let event: CameraEvent

}
