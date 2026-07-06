# Adster Flutter SDK

The `adster_flutter_sdk` gives your Flutter app complete monetization support through a single mediation layer. It supports Banner, Native, Custom Native, Interstitial, Rewarded, App Open, Unified, and Carousel ad formats on both Android and iOS, with revenue reporting, click/impression callbacks, and GAM predefined custom targeting.

- **Android** native dependency: `com.adstertech:orchestrationsdk:2.6.3`
- **iOS** native dependency: `Adster ~> 1.6.6`

If you get stuck at any point, contact [support@adster.tech](mailto:support@adster.tech).

---

## Table of contents

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Android setup](#android-setup)
4. [iOS setup](#ios-setup)
5. [Quick start](#quick-start)
6. [Ad sizes](#ad-sizes)
7. [Ad formats](#ad-formats)
   - [Banner](#banner-ads)
   - [Native](#native-ads)
   - [Custom native](#custom-native-ads)
   - [Interstitial](#interstitial-ads)
   - [Rewarded](#rewarded-ads)
   - [App Open](#app-open-ads)
   - [Unified](#unified-ads)
   - [Carousel banner](#carousel-banner-ads)
   - [Carousel native](#carousel-native-ads)
8. [Predefined custom targeting & PPID](#predefined-custom-targeting--ppid)
9. [Callbacks reference](#callbacks-reference)
10. [Troubleshooting](#troubleshooting)
11. [License](#license)

---

## Requirements

| Platform | Minimum |
|----------|---------|
| Flutter  | 3.9.0 |
| Dart     | 3.9.0 |
| Android  | `minSdkVersion` 23, `compileSdk` 35 |
| iOS      | iOS 13.0 |

---

## Installation

Add the package with the Flutter CLI:

```shell
flutter pub add adster_flutter_sdk
```

or add it to `pubspec.yaml` and run `flutter pub get`:

```yaml
dependencies:
  adster_flutter_sdk: ^1.2.0
```

Import it wherever you show ads:

```dart
import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
```

There is **no manual `initialize()` call** — the SDK initializes itself from your platform configuration the first time an ad is requested. Complete the platform setup below before requesting an ad.

---

## Android setup

### 1. Enable `mavenCentral()`

The native SDK is published on Maven Central. Modern Flutter projects already include it; if yours is older, make sure it is present.

**`android/settings.gradle` (recommended)**

```groovy
dependencyResolutionManagement {
  repositories {
    google()
    mavenCentral()
  }
}
```

**or `android/build.gradle`**

```groovy
allprojects {
  repositories {
    google()
    mavenCentral()
  }
}
```

### 2. Set the minimum SDK version

In `android/app/build.gradle`:

```groovy
android {
  defaultConfig {
    minSdkVersion 23
  }
}
```

### 3. Add permissions and the AdMob application id

In `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="com.google.android.gms.permission.AD_ID" />
```

Inside the `<application>` tag, add your AdMob application id:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy" />
```

> For testing without your own AdMob account you may use Google's sample id
> `ca-app-pub-3940256099942544~3347511713`. Replace it with your real id before release.

---

## iOS setup

### 1. Add the AdMob application id to `Info.plist`

In `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

> For testing you may use `ca-app-pub-3940256099942544~1458002511`. Replace it with your real id before release.

### 2. Set the minimum deployment target

Ensure `ios/Podfile` targets iOS 13 or higher:

```ruby
platform :ios, '13.0'
```

### 3. Install pods

```shell
cd ios
pod install --repo-update
```

---

## Quick start

Every ad format follows one of two patterns.

**Widget-based** (Banner, Native, Custom Native, Unified, Carousel) — drop the widget into your tree and it loads itself:

```dart
AdsterBannerAd(
  adPlacementName: "your_placement_name",
  adSize: AdsterAdSize.medium,
  onFailure: (error) => Text("Ad not loaded: ${error.message}"),
);
```

**Controller-based** (Interstitial, Rewarded, App Open) — create the object once, call `loadAd`, then show:

```dart
final interstitial = AdsterInterstitialAds();

await interstitial.loadAd(adPlacementName: "your_placement_name");
await interstitial.showInterstitialAd();
```

---

## Ad sizes

`AdsterAdSize` provides the standard banner sizes plus a custom constructor.

| Size | Dimensions (W x H) |
|------|--------------------|
| `AdsterAdSize.small` | 320 x 50 |
| `AdsterAdSize.medium` | 300 x 250 |
| `AdsterAdSize.large` | 600 x 600 |
| `AdsterAdSize.custom(width, height)` | Custom |

Each size exposes `.width` and `.height` so you can size loading placeholders to match.

---

## Ad formats

All examples assume `import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';`.

Every format also accepts the optional `customTargetArgs` and `publisherProvidedId` parameters described in [Predefined custom targeting & PPID](#predefined-custom-targeting--ppid). They are omitted from the examples below for brevity.

### Banner ads

```dart
AdsterBannerAd(
  adPlacementName: "adster_banner_300x250",
  adSize: AdsterAdSize.medium,
  loadingWidget: const SizedBox(
    width: 300,
    height: 250,
    child: Center(child: CircularProgressIndicator()),
  ),
  clickCallback: AdsterBannerAdCallback(
    onAdClicked: () => debugPrint("Banner clicked"),
    onAdImpression: () => debugPrint("Banner impression"),
    onAdRevenuePaid: (revenue, adUnitId, network, currency, precisionType) {
      debugPrint("Banner revenue: $revenue $currency ($network)");
    },
  ),
  onFailure: (error) => Text("Banner not loaded: ${error.message}"),
);
```

### Native ads

Your `onAdLoaded` builder receives the ad data, the platform media view, and a click handler. Bind the click handler to the components the user can tap so clicks are tracked correctly.

```dart
AdsterNativeAd(
  adPlacementName: "adster_native_test",
  clickCallback: AdsterNativeAdCallback(
    onAdClicked: () => debugPrint("Native clicked"),
    onAdImpression: () => debugPrint("Native impression"),
  ),
  onAdLoaded: (value, mediaView, clickHandler) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(child: mediaView),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => clickHandler(AdsterNativeAdClickComponent.headline),
                  child: Text(
                    value.headLine ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () => clickHandler(AdsterNativeAdClickComponent.body),
                  child: Text(value.body ?? ""),
                ),
                MaterialButton(
                  onPressed: () =>
                      clickHandler(AdsterNativeAdClickComponent.callToAction),
                  child: Text(value.callToAction ?? ""),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
  onFailure: (error) => Text(error.message ?? ""),
);
```

**Native click components** (bind each tappable element):
`AdsterNativeAdClickComponent.body`, `.callToAction`, `.headline`, `.logo`, `.ratingBar`.

### Custom native ads

For GAM custom native formats. The builder gives you async accessors for the format's named assets.

```dart
AdsterNativeCustomAd(
  adPlacementName: "adster_custom_native_test",
  onAdLoaded: (ad, getText, getImageUrl, performClick, recordImpression) {
    recordImpression();
    return FutureBuilder<String?>(
      future: getText("Headline"),
      builder: (context, snapshot) {
        return InkWell(
          onTap: () => performClick("Headline"),
          child: Text(snapshot.data ?? ""),
        );
      },
    );
  },
  onFailure: (error) => Text("Custom native not loaded: ${error.message}"),
);
```

### Interstitial ads

Create the object once (e.g. in a controller) so it is not reloaded on every rebuild. Load, then show.

```dart
final interstitialAds = AdsterInterstitialAds();

await interstitialAds.loadAd(
  adPlacementName: "adster_interstitial_test",
  callback: AdsterInterstitialAdsCallback(
    onAdClicked: () => debugPrint("Interstitial clicked"),
    onAdImpression: () => debugPrint("Interstitial impression"),
    onAdOpened: () => debugPrint("Interstitial opened"),
    onAdClosed: () => debugPrint("Interstitial closed"),
    onAdRevenuePaid: (revenue, adUnitId, network, currency, precisionType) {
      debugPrint("Interstitial revenue: $revenue $currency");
    },
    onAdFailToPresentFullScreenContentWithError: (error) {
      debugPrint("Interstitial failed to present: ${error.message}");
    },
  ),
);

await interstitialAds.showInterstitialAd();

// To request a fresh ad on the same object (reuses the last placement + targeting):
await interstitialAds.reloadAd();
```

### Rewarded ads

```dart
final rewardedAds = AdsterRewardedAds();

await rewardedAds.loadAd(
  adPlacementName: "adster_rewarded_test",
  callback: AdsterRewardedAdCallback(
    onAdClicked: () => debugPrint("Rewarded clicked"),
    onAdImpression: () => debugPrint("Rewarded impression"),
    onUserEarnedReward: (rewardAmount) => debugPrint("Reward: $rewardAmount"),
    onVideoStart: () => debugPrint("Video start"),
    onVideoComplete: () => debugPrint("Video complete"),
    onVideoClosed: () => debugPrint("Video closed"),
    onAdRevenuePaid: (revenue, adUnitId, network, currency, precisionType) {
      debugPrint("Rewarded revenue: $revenue $currency");
    },
  ),
);

await rewardedAds.showRewardedAd();
```

### App Open ads

App Open ads are shown automatically as soon as they load. Call `loadAd` when your app returns to the foreground.

```dart
final appOpenedAds = AdsterAppOpenedAds();

appOpenedAds
    .loadAd(
      adPlacementName: "adster_appopen_test",
      callback: AdsterAppOpenedAdCallback(
        onAdClicked: () => debugPrint("App open clicked"),
        onAdImpression: () => debugPrint("App open impression"),
        onAdOpened: () => debugPrint("App open opened"),
        onAdClosed: () => debugPrint("App open closed"),
        onFailure: (code, message) => debugPrint("App open failed: ($code) $message"),
        onAdRevenuePaid: (revenue, adUnitId, network, currency, precisionType) {
          debugPrint("App open revenue: $revenue $currency");
        },
      ),
    )
    .then((_) => debugPrint("App open loaded & shown"))
    .onError((error, _) => debugPrint("App open error: $error"));
```

### Unified ads

A unified placement can return a banner, a native, or a custom native ad. Provide a builder for each type you support.

```dart
AdsterUnifiedAd(
  adPlacementName: "adster_unified_test",
  bannerAdSize: AdsterAdSize.medium,
  unifiedAdClickCallback: AdsterBannerAdCallback(
    onAdClicked: () => debugPrint("Unified clicked"),
    onAdImpression: () => debugPrint("Unified impression"),
    onAdRevenuePaid: (revenue, adUnitId, network, currency, precisionType) {
      debugPrint("Unified revenue: $revenue $currency");
    },
  ),
  onBannerAdLoaded: (bannerView) => bannerView,
  onNativeAdLoaded: (value, mediaView, clickHandler) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(child: mediaView),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => clickHandler(AdsterNativeAdClickComponent.headline),
                  child: Text(value.headLine ?? ""),
                ),
                MaterialButton(
                  onPressed: () =>
                      clickHandler(AdsterNativeAdClickComponent.callToAction),
                  child: Text(value.callToAction ?? ""),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
  // Optional: handle GAM custom native formats returned by the placement.
  onCustomNativeAdLoaded: (ad, getText, getImageUrl, performClick, recordImpression) {
    recordImpression();
    return FutureBuilder<String?>(
      future: getText("Headline"),
      builder: (context, snapshot) => Text(snapshot.data ?? ""),
    );
  },
  onFailure: (error) => Text("Unified not loaded: ${error.message} (${error.code})"),
);
```

### Carousel banner ads

Returns a list of banner views. Provide your own carousel/pager, or omit `onAdLoaded` to use the built-in `PageView`.

```dart
AdsterCarouselBannerAd(
  adPlacementName: "adster_carousel_banner_test",
  adSize: AdsterAdSize.medium,
  onAdLoaded: (bannerViews) => SizedBox(
    height: 250,
    child: PageView(children: bannerViews),
  ),
  onFailure: (error) => Text("Carousel banner not loaded: ${error.message}"),
);
```

### Carousel native ads

Returns a list of items, each with the native ad data, a media view, and a click handler.

```dart
AdsterCarouselNativeAd(
  adPlacementName: "adster_carousel_native_test",
  onAdLoaded: (items) {
    return PageView(
      children: items.map((item) {
        return Column(
          children: [
            Expanded(child: item.mediaView),
            InkWell(
              onTap: () => item.clickHandler(AdsterNativeAdClickComponent.headline),
              child: Text(item.ad.headLine ?? ""),
            ),
          ],
        );
      }).toList(),
    );
  },
  onFailure: (error) => Text("Carousel native not loaded: ${error.message}"),
);
```

---

## Predefined custom targeting & PPID

You can attach **predefined custom targeting values** and a **publisher provided identifier (PPID)** to any ad request. Both are honoured for **Google Ad Manager (GAM)** demand and are silently ignored by other networks. This works on **Android and iOS** for **every ad format**.

Two optional parameters are available on every widget and every `loadAd` call:

| Parameter | Type | Description |
|-----------|------|-------------|
| `customTargetArgs` | `Map<String, String>?` | Key/value pairs sent as GAM custom targeting. |
| `publisherProvidedId` | `String?` | The PPID sent with the request. |

### Widget-based formats

```dart
AdsterBannerAd(
  adPlacementName: "your_placement_name",
  adSize: AdsterAdSize.medium,
  customTargetArgs: const {
    "content_category": "sports",
    "user_tier": "premium",
  },
  publisherProvidedId: "user-ppid-123",
  onFailure: (error) => Text(error.message ?? ""),
);
```

The same two parameters exist on `AdsterNativeAd`, `AdsterNativeCustomAd`, `AdsterUnifiedAd`, `AdsterCarouselBannerAd`, and `AdsterCarouselNativeAd`.

### Controller-based formats

```dart
await AdsterInterstitialAds().loadAd(
  adPlacementName: "your_placement_name",
  customTargetArgs: const {"content_category": "news"},
  publisherProvidedId: "user-ppid-123",
);
```

The same two parameters exist on `AdsterRewardedAds.loadAd(...)` and `AdsterAppOpenedAds.loadAd(...)`. For these controllers, the values you pass to `loadAd` are also reused by `reloadAd()`.

> **Tip:** define your targeting map and PPID once and reuse them across placements, as shown in `example/lib/targeting_demo.dart`.

---

## Callbacks reference

### Revenue callback

Every `onAdRevenuePaid` callback has the signature:

```dart
void Function(
  double? revenue,
  String? adUnitId,
  String? network,
  String? currency,
  AdsterPrecisionType? precisionType,
);
```

`AdsterPrecisionType` is one of `unknown`, `estimated`, `publisherProvided`, or `precise`.

### Callback classes by format

| Format | Callback class | Notable callbacks |
|--------|----------------|-------------------|
| Banner / Carousel banner | `AdsterBannerAdCallback` | `onAdClicked`, `onAdImpression`, `onAdRevenuePaid` |
| Native / Carousel native | `AdsterNativeAdCallback` | `onAdClicked?`, `onAdImpression?`, `onAdRevenuePaid?` |
| Interstitial | `AdsterInterstitialAdsCallback` | `onAdOpened`, `onAdClosed`, `onAdFailToPresentFullScreenContentWithError?` |
| Rewarded | `AdsterRewardedAdCallback` | `onUserEarnedReward(int?)`, `onVideoStart/Complete/Closed` |
| App Open | `AdsterAppOpenedAdCallback` | `onAdOpened`, `onAdClosed`, `onFailure(int, String)` |
| Unified | `AdsterBannerAdCallback` (as `unifiedAdClickCallback`) | shared banner-style callbacks |

### Error handling

Widget `onFailure` builders receive an `AdsterAdsException` with `code` and `message`. For controller-based formats, `loadAd` returns a `Future` you can chain `.onError(...)` on, and the failure is also surfaced through the callback.

---

## Troubleshooting

- **Ads never fill in a test build** — verify the placement name, that the AdMob application id is set (`AndroidManifest.xml` / `Info.plist`), and that the device has network access.
- **iOS build/link errors after upgrading** — run `pod install --repo-update` from the `ios` directory and rebuild. Ensure the deployment target is iOS 13+.
- **Android `minSdkVersion` error** — raise `minSdkVersion` to 23.
- **Missing dependency on Android** — confirm `mavenCentral()` is in your repositories.
- **Custom targeting has no effect** — targeting only applies to GAM demand; other networks ignore it. Confirm the placement is served by GAM and the keys exist in your GAM setup.
- **Native clicks not tracked** — make sure each tappable element calls `clickHandler` with the matching `AdsterNativeAdClickComponent`.

For anything else, reach out to [support@adster.tech](mailto:support@adster.tech).

---

## License

This project is licensed under the MIT License. See the [LICENSE](https://pub.dev/packages/adster_flutter_sdk/license) file for details.
