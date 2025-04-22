# 🚀 Adster Flutter SDK Example

This Flutter project demonstrates the integration of the `adster_flutter_sdk` for showing various ad formats including:

- Banner Ads
- Native Ads
- Interstitial Ads
- Rewarded Ads

---

## 📱 Android Setup

### ✅ Manifest Changes Required for SDK

Please add the following permissions to your Android `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

If you don’t have an AdMob account and want to test SDK initialization, also add:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-7640426597645136~3443205346" />
```

---

## 🍏 iOS Setup

```txt
Coming soon
```

---

## 📐 Banner Ads

### 📏 Banner Ad Sizes

| Adster Ad Size       | Dimensions (WxH)  |
|----------------------|------------------|
| `AdsterAdSize.small` | 320 x 50         |
| `AdsterAdSize.medium`| 300 x 250        |
| `AdsterAdSize.custom`| Custom (w x h)   |

### ✅ Example Usage

```dart
import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';

AdsterBannerAd(
  adPlacementName: "adster_banner_320x50",
  adSize: AdsterAdSize.small,
  loadingWidget: SizedBox(
    width: AdsterAdSize.small.width,
    height: AdsterAdSize.small.height,
    child: Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 10),
          Text("Loading...."),
        ],
      ),
    ),
  ),
  onFailure: (AdsterAdsException error) {
    return Text("Banner not loaded: ${error.message}");
  },
);
```

---

## 🎨 Native Ads

### ✅ Example Usage

```dart
AdsterNativeAd(
  adPlacementName: "adster_native_test",
  onAdLoaded: (value, widget) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          SizedBox(width: 10),
          Expanded(child: widget),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: value.imageUrl ?? "",
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          value.headLine ?? "",
                          maxLines: 2,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(value.body ?? ""),
                  SizedBox(height: 5),
                  MaterialButton(
                    onPressed: () {},
                    color: Colors.grey,
                    child: Text(value.callToAction ?? ""),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
  onFailure: (AdsterAdsException error) {
    return Text(error.message ?? "");
  },
);
```

---

## 🔒 License

This project is licensed under the MIT License.  
See the [LICENSE](https://pub.dev/packages/adster_flutter_sdk/license) file for details.