import Foundation

public protocol WhisperDelegate: AnyObject {
    func whisper(_ aWhisper: Whisper, didUpdateProgress progress: Double)
    func whisper(_ aWhisper: Whisper, didProcessNewSegments segments: [Segment], atIndex index: Int)
    func whisper(_ aWhisper: Whisper, didCompleteWithSegments segments: [Segment])
    func whisper(_ aWhisper: Whisper, didErrorWith error: Error)
    // 可选：token 级回调（需要 params.token_timestamps = true）
    func whisper(_ aWhisper: Whisper, didProcessNewTokens tokens: [Token], inSegmentAt index: Int)
}

public extension WhisperDelegate {
    func whisper(_ aWhisper: Whisper, didUpdateProgress progress: Double) {
        //
    }

    func whisper(_ aWhisper: Whisper, didProcessNewSegments segments: [Segment], atIndex index: Int) {
        //
    }

    func whisper(_ aWhisper: Whisper, didCompleteWithSegments segments: [Segment]) {
        //
    }

    func whisper(_ aWhisper: Whisper, didErrorWith error: Error) {
        //
    }

    func whisper(_ aWhisper: Whisper, didProcessNewTokens tokens: [Token], inSegmentAt index: Int) {
        //
    }
}
