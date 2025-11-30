import Foundation
import whisper_cpp

// swiftlint:disable identifier_name
@dynamicMemberLookup
public class WhisperParams {
    public static let `default` = WhisperParams(strategy: .greedy)

    internal var whisperParams: whisper_full_params
    internal var _language: UnsafeMutablePointer<CChar>?
    // Extra string fields managed like `language`
    internal var _initialPrompt: UnsafeMutablePointer<CChar>?

    public init(strategy: WhisperSamplingStrategy = .greedy) {
        self.whisperParams = whisper_full_default_params(whisper_sampling_strategy(rawValue: strategy.rawValue))
        self.language = .auto
    }

    deinit {
        if let _language = _language {
            free(_language)
        }
        if let _initialPrompt = _initialPrompt {
            free(_initialPrompt)
        }
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<whisper_full_params, T>) -> T {
        get { whisperParams[keyPath: keyPath] }
        set { whisperParams[keyPath: keyPath] = newValue }
    }

    public var language: WhisperLanguage {
        get { .init(rawValue: String(Substring(cString: whisperParams.language)))! }
        set {
            guard let pointer = strdup(newValue.rawValue) else { return }

            if let _language = _language {
                free(_language) // Free previous reference since we're creating a new one
            }

            self._language = pointer
            whisperParams.language = UnsafePointer(pointer)
        }
    }

    // MARK: - Convenience wrappers for frequently used params

    public var nThreads: Int32 {
        get { whisperParams.n_threads }
        set { whisperParams.n_threads = newValue }
    }

    public var noContext: Bool {
        get { whisperParams.no_context }
        set { whisperParams.no_context = newValue }
    }

    public var maxTextContext: Int32 {
        get { whisperParams.n_max_text_ctx }
        set { whisperParams.n_max_text_ctx = newValue }
    }

    public var offsetMs: Int32 {
        get { whisperParams.offset_ms }
        set { whisperParams.offset_ms = newValue }
    }

    public var durationMs: Int32 {
        get { whisperParams.duration_ms }
        set { whisperParams.duration_ms = newValue }
    }

    public var translate: Bool {
        get { whisperParams.translate }
        set { whisperParams.translate = newValue }
    }

    public var singleSegment: Bool {
        get { whisperParams.single_segment }
        set { whisperParams.single_segment = newValue }
    }

    public var printTimestamps: Bool {
        get { whisperParams.print_timestamps }
        set { whisperParams.print_timestamps = newValue }
    }

    @available(*, deprecated, message: "Token-level timestamps are experimental and disabled. Token callbacks are always emitted; timestamps may be zero. Compute in app layer.")
    public var tokenTimestamps: Bool {
        get { false }
        set { whisperParams.token_timestamps = newValue }
    }

    public var maxLen: Int32 {
        get { whisperParams.max_len }
        set { whisperParams.max_len = newValue }
    }

    public var maxTokens: Int32 {
        get { whisperParams.max_tokens }
        set { whisperParams.max_tokens = newValue }
    }

    public var temperature: Float {
        get { whisperParams.temperature }
        set { whisperParams.temperature = newValue }
    }

    public var temperatureInc: Float {
        get { whisperParams.temperature_inc }
        set { whisperParams.temperature_inc = newValue }
    }

    public var entropyThreshold: Float {
        get { whisperParams.entropy_thold }
        set { whisperParams.entropy_thold = newValue }
    }

    public var logprobThreshold: Float {
        get { whisperParams.logprob_thold }
        set { whisperParams.logprob_thold = newValue }
    }

    public var noSpeechThreshold: Float {
        get { whisperParams.no_speech_thold }
        set { whisperParams.no_speech_thold = newValue }
    }

    public var suppressBlank: Bool {
        get { whisperParams.suppress_blank }
        set { whisperParams.suppress_blank = newValue }
    }

    // 跨版本兼容：多数稳定版本使用 `suppress_non_speech_tokens`
    public var suppressNonSpeechTokens: Bool {
        get { whisperParams.suppress_non_speech_tokens }
        set { whisperParams.suppress_non_speech_tokens = newValue }
    }

    @available(*, deprecated, message: "Experimental speed_up is disabled.")
    public var speedUp: Bool {
        get { false }
        set { whisperParams.speed_up = newValue }
    }

    public var audioCtx: Int32 {
        get { whisperParams.audio_ctx }
        set { whisperParams.audio_ctx = newValue }
    }

    public var splitOnWord: Bool {
        get { whisperParams.split_on_word }
        set { whisperParams.split_on_word = newValue }
    }

    public var maxInitialTs: Float {
        get { whisperParams.max_initial_ts }
        set { whisperParams.max_initial_ts = newValue }
    }

    public var greedyBestOf: Int32 {
        get { whisperParams.greedy.best_of }
        set { whisperParams.greedy.best_of = newValue }
    }

    public var beamSize: Int32 {
        get { whisperParams.beam_search.beam_size }
        set { whisperParams.beam_search.beam_size = newValue }
    }

    public var beamPatience: Float {
        get { whisperParams.beam_search.patience }
        set { whisperParams.beam_search.patience = newValue }
    }

    public var lengthPenalty: Float {
        get { whisperParams.length_penalty }
        set { whisperParams.length_penalty = newValue }
    }

    // MARK: - String based params
    public var initialPrompt: String? {
        get {
            guard let cstr = whisperParams.initial_prompt else { return nil }
            return String(cString: cstr)
        }
        set {
            // free previous
            if let _initialPrompt = _initialPrompt { free(_initialPrompt) }
            if let str = newValue, let ptr = strdup(str) {
                _initialPrompt = ptr
                whisperParams.initial_prompt = UnsafePointer(ptr)
            } else {
                _initialPrompt = nil
                whisperParams.initial_prompt = nil
            }
        }
    }

    // 注意：`suppress_regex` 并非所有 whisper.cpp 版本都存在，此处不暴露；如需使用请在确认底层字段后再扩展。
}
// swiftlint:enable identifier_name
