/**
 The physical camera position preferred when a camera flow starts.
*/
public enum CameraPosition: Sendable, Equatable {
    case back
    case front
}

extension CameraPosition {

    var opposite: CameraPosition {
        switch self {
        case .back:
            .front
        case .front:
            .back
        }
    }

}
