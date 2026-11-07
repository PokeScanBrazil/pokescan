# Roadmap

PokéScan is in early development. This is the work I plan to do next, roughly in order.

## 1. Reliable scanning
- [ ] Parse card name and collection number robustly (`025/165`, promo codes, secret rares like `201/165`)
- [ ] Use `VNDetectRectanglesRequest` to find the card and crop/deskew it before OCR
- [ ] Throttle OCR frames and only fire a lookup when the reading is stable across frames
- [ ] Haptic and visual feedback when a card is recognized
- [ ] Manual entry / correction screen when OCR confidence is low
- [ ] Move to the iOS 16 `DataScannerViewController` where available, keep Vision as fallback

## 2. Card details
- [ ] Card detail screen: image, edition, year, rarity and type returned by the backend
- [ ] Loading, empty and error states
- [ ] Image caching

## 3. Collection
- [ ] Save scanned cards to a local collection (SwiftData / Core Data)
- [ ] Quantity, condition and language per card
- [ ] Search and filter by edition, rarity and type
- [ ] Export the collection to CSV

## 4. Engineering
- [ ] Configurable backend URL per build configuration (Debug / Release)
- [ ] Migrate networking to Swift Concurrency end to end and remove debug prints
- [ ] Unit tests for the ViewModel and text parsing; snapshot tests for the views
- [ ] GitHub Actions: build, lint and test on every push
- [ ] Fastlane lane for TestFlight
- [ ] Localization (Portuguese and English)
- [ ] Accessibility (VoiceOver labels, Dynamic Type)

## 5. Release
- [ ] App icon and onboarding
- [ ] TestFlight beta with collector friends
- [ ] App Store release
