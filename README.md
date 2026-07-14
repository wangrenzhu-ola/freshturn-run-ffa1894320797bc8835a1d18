# FreshTurn

FreshTurn turns one grocery receipt into a short, user-confirmed perishable rescue queue. Receipt recognition runs on device, cloud parsing is opt-in and text-only, and nothing is saved until the user confirms the candidates.

## Build

```sh
xcodegen generate
xcodebuild -project FreshTurn.xcodeproj -scheme FreshTurn -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
swift test
```

The app uses Swift 5 language mode and targets iOS 14. A Kimi-compatible backend proxy URL may be supplied as the non-secret `KIMI_PROXY_URL` Info.plist value. No provider credential belongs in the app.

