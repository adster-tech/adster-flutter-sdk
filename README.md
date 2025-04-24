# 🚀 Adster Flutter SDK Example

This Flutter project demonstrates the integration of the `adster_flutter_sdk` for showing various ad formats including:

- Banner Ads
- Native Ads
- Interstitial Ads
- Rewarded Ads

---

## 📱 Android Setup

### 🔐 Authentication Setup for Adster Orchestration SDK

To securely access the native Adster SDK hosted on GitHub Packages, your project must provide authentication credentials. These are required to fetch the dependency from our private Maven repository.

#### 📦 Step 1: Add Maven Credentials

You can provide the credentials in **either of two ways**:

##### 🔧 Option A: Add to `gradle.properties`

Add the following lines to either your project’s `android/gradle.properties` file **or** your global `~/.gradle/gradle.properties`:

```properties
adsterMavenUsername=YOUR_GITHUB_USERNAME
adsterMavenPassword=YOUR_PERSONAL_ACCESS_TOKEN
```

> 💡 You can generate a [GitHub Personal Access Token (classic)](https://github.com/settings/tokens?type=beta) with `read:packages` and `repo` scopes.

##### 🌐 Option B: Use Environment Variables (ideal for CI/CD)

Alternatively, you can export these environment variables in your terminal or CI setup:

```bash
export ADSTER_MAVEN_USERNAME=YOUR_GITHUB_USERNAME
export ADSTER_MAVEN_PASSWORD=YOUR_PERSONAL_ACCESS_TOKEN
```

---

#### ⚠️ Build Fails Without Credentials

If credentials are not set, the build will fail fast with a clear error message:

```text
❗ Missing Adster Maven credentials.
Please set 'adsterMavenUsername' and 'adsterMavenPassword'
in gradle.properties or as environment variables.
```

#### ✅ That's It!

Once credentials are provided, the Flutter plugin will be able to fetch and integrate the native orchestration SDK seamlessly.

If you face any issues, feel free to contact [support@adster.tech](mailto:support@adster.tech).

---

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