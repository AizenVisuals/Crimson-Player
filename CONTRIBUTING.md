# Contributing

Crimson Player is currently an **Android-first preview**. Please prioritize correctness, usability and real-device testing over promises of unimplemented features.

## Bugs

A report should identify the **exact app** that crashed, version/release and APK architecture, Android version, reproduction steps, expected/actual result, and redacted logs/screenshots where relevant. Do not share private music links or tokens.

## Local build

```sh
flutter create --platforms=android --org com.aizenvisuals .
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```

## Standards

- Follow [DESIGN.md](DESIGN.md): real artwork, honest placeholders and genuine animations.
- Provide accessible states and tests for behavior changes.
- Never include unlicensed music or DRM circumvention.
- Preserve attribution and corresponding source for any GPL-derived code.
- Discuss large changes in an issue before opening a PR.

Contributions are distributed under the project's [GPL-3.0 license](LICENSE).
