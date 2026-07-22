## 1.2.6
- Fixed Android native media rendering by sizing the native media host to the Flutter platform view bounds.
- Aligned Android native image URL serialization with the Flutter `imageUrl` field.
- Loaded Android native ad logos into the native platform view and hid the logo slot when no logo is available.

## 1.2.5
- Improved iOS native and unified native ad card styling with explicit dark background, readable text colors, stronger CTA styling, and better media/card contrast.

## 1.2.4
- Fixed iOS native and unified native ad clicks by rendering a registered `MediationNativeAdView` instead of exposing only the media view.
- Fixed iOS native ad rendering in compact Flutter layouts by using a programmatic native ad view sized for the Flutter slot.
- Forwarded iOS native click events through the native and unified bridges and restored click/impression callbacks for native ads.

## 1.2.3
- Updated Android SDK to version 2.6.4
- Updated iOS SDK (Adster) to version 1.6.8
- Added compatibility for the newer iOS mediation delegate surface

## 1.2.2
- Updated iOS SDK (Adster) to version 1.6.7
- Declared the Google Mobile Ads SDK 13.2 dependency so the `GoogleMobileAds` module resolves for consumer apps (fixes "Module 'GoogleMobileAds' not found")
- Raised the minimum iOS deployment target to 15.0
- Adapted the custom native (custom format) image lookup to Adster 1.6.7, where `getImage(for:)` moved to the `MediationNativeCustomFormatAdGAM` protocol

## 1.2.1
- Updated Android SDK to version 2.6.3
- Updated iOS SDK to version 1.6.6
- Added predefined custom targeting (`customTargetArgs`) and publisher provided id (`publisherProvidedId`) support to every ad format on both Android and iOS
- Renamed the native ad's `customTargetArgsIOS`/`publisherProvidedIdIOS` params to the cross-platform `customTargetArgs`/`publisherProvidedId`
- Updated the example app to demonstrate targeting across all formats and rewrote the README integration guide

## 1.2.0
- Updated Android SDK to version 2.5.1
- Updated iOS SDK to version 1.5.4
- Replaced ad revenue callbacks with the new 5-argument signature including currency and precision type
- Added carousel banner, carousel native, and custom native ad APIs

## 1.1.9
- Updated Android SDK to version 2.4.3

## 1.1.8
- Updated iOS SDK to version 1.4.5

## 1.0.0
- Initial release

## 1.0.1
- Documentation added

## 1.0.2
- UI Fixings

## 1.0.3
- repo endpoint changed for Android
- Firebase missing messagingSenderId issue fixed

## 1.0.6
- Added support for play services ads 24.3.0

## 1.0.7
- iOS configuration added
- Unified Ads
- onAdRevenuePaid added

## 1.0.8
- Updated Android SDK to version 2.2.6
- Updated iOS SDK to version 1.2.9
- Fixed iOS protocol conformance for updated SDK

## 1.0.9
- Updated minimum iOS deployment target to 14.0 (required by Adster iOS SDK 1.2.9)

## 1.1.0
- Documentation updated

## 1.1.1
- Upgraded Flutter SDK constraint to 3.9.0
- Upgraded Dart SDK constraint to 3.9.0

## 1.1.2
- Updated iOS SDK to version 1.3.1
- Updated minimum iOS deployment target to 13.0

## 1.1.3
- Changed AdsterAdSize from enum to class for custom size support
- Fixed AdsterAdSize.custom() recursive call bug
- Fixed AdsterAdSize.toString() formatting

## 1.1.4
- Updated Android SDK to version 2.2.6
- Added Material Components dependency for Android

## 1.1.5
- Updated Android SDK to version 2.2.7

## 1.1.6
- Updated Android SDK to version 2.3.7
- Updated iOS SDK to version 1.4.0

## 1.1.7
- Updated Android SDK to version 2.4.2
- Updated iOS SDK to version 1.4.4
