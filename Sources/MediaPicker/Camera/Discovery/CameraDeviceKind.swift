/** Camera hardware categories used to define a predictable selection priority. */
enum CameraDeviceKind: Sendable, Equatable {
    case triple
    case dualWide
    case dual
    case trueDepth
    case wideAngle
    case ultraWide
    case telephoto
    case external
    case unknown
}
