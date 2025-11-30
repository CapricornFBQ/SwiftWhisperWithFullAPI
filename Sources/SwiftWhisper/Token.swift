import Foundation
import whisper_cpp

public struct Token: Equatable {
    public let id: Int32
    public let text: String
    public let startTimeMs: Int
    public let endTimeMs: Int
    public let p: Float
    public let pt: Float
    public let ptsum: Float
    public let vlen: Float // whisper_token_data.vlen is float in current headers
}
