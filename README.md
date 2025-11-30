# SwiftWhisperWithFullAPI (fork)

本仓库是对 exPHAT/SwiftWhisper 的 fork，目标是在 Swift 侧尽可能完整映射 whisper.cpp 的常用参数，并增加 Token 级回调，便于做流式识别与实时 UI 渲染。

Powered by [whisper.cpp](https://github.com/ggerganov/whisper.cpp)。

## 安装

SPM 方式与原版一致；将依赖指向本仓库地址即可。

## 快速使用

```swift
import SwiftWhisper

let modelData: Data = ... // 从 Bundle 读取 .bin
let params = WhisperParams.default
params.nThreads = 3
params.noContext = true
params.suppressBlank = true
params.suppressNonSpeechTokens = true

let whisper = Whisper(fromData: modelData, withParams: params)
whisper.delegate = self

let segments = try await whisper.transcribe(audioFrames: pcm16kMono)
print("Transcribed:", segments.map(\.text).joined())
```

### Token 级回调（稳定）

Token 回调总是触发；若底层未计算到 token 级时间戳，startTimeMs/endTimeMs 可能为 0。建议在业务层合成严格递增时间戳并重基到全局时间：

```swift
extension MyHandler: WhisperDelegate {
    func whisper(_ aWhisper: Whisper, didProcessNewTokens tokens: [Token], inSegmentAt index: Int) {
        // 建议：做最长公共前缀 + 时间戳单调 去重后再上屏
    }
}
```

## 参数覆盖范围（本 fork 新增便捷属性）

不同 whisper.cpp 版本字段可能略有变化；以下映射基于较新的版本：

- 线程与上下文
  - `nThreads` ⇔ `n_threads`
  - `noContext` ⇔ `no_context`
  - `maxTextContext` ⇔ `n_max_text_ctx`
  - `offsetMs` / `durationMs`
  - `audioCtx` ⇔ `audio_ctx`
- 采样/束搜索
  - `greedyBestOf` ⇔ `greedy.best_of`
  - `beamSize` / `beamPatience` ⇔ `beam_search.beam_size` / `patience`
  - `maxLen` / `maxTokens`
  - `temperature` / `temperatureInc`
  - `lengthPenalty`
- 抑制与阈值
  - `suppressBlank`
  - `suppressNonSpeechTokens`（旧版可能命名 `suppress_nst`）
  - `suppressRegex`（字符串）
  - `entropyThreshold` / `logprobThreshold` / `noSpeechThreshold`
  - `maxInitialTs` / `splitOnWord`
- 语言与提示
  - `language` / `translate`
  - `initialPrompt`（字符串）
  - `tokenTimestamps`（启用 token 级时间戳）

注：依赖的 `whisper.cpp` 子模块需要 `git submodule update --init --recursive` 拉齐后编译。

## 流式识别实践建议

- 滑窗 + 无上下文：`noContext = true`，窗口 0.7–1.5s；结合你方 VAD/带宽比策略。
- Token 实时上屏：直接使用回调的 token 文本；若时间戳为 0，则在业务层按批内序（如 10ms 间隔）合成并重基到全局时间。
- 抑制：`suppressBlank = true`，`suppressNonSpeechTokens = true`；必要时 `suppressRegex`。
- 性能：`nThreads` 控制在 2–3；积压严重时跳过一次窗口解码以追上实时。

## TODO（实施记录，改完就打勾）

- [x] 增加 Token 结构与回调（`didProcessNewTokens`）
- [x] 为常用 whisper.cpp 字段增加便捷属性（`WhisperParams` 扩展）
- [x] 管理 `initialPrompt` / `suppressRegex` 的 C 字符串内存
- [x] README：参数覆盖范围 / 流式建议 / 示例
- [ ] 跨版本兼容：旧名 `suppress_nst` 等字段别名支持
- [ ] 文档补充：字段与 whisper.cpp 版本对照表
- [ ] 示例工程（可选）

## 其他（原 README 摘要）

- 模型下载：可参考 Hugging Face `ggerganov/whisper.cpp`。
- CoreML：保留与原版一致的 `-encoder.mlmodelc` 约定；仅在从文件 URL 初始化时自动检测。
- Debug 性能：可参考原版 `fast` 分支或使用 Release 构建。
