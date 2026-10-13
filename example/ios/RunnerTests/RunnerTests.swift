import UIKit
import XCTest
import AdsFramework
@testable import adster_flutter_sdk

final class RunnerTests: XCTestCase {
  func testNativeMediaFillsSlotAcrossPipResizes() {
    let ad = StubNativeAd()
    let view = AdsterNativeMediaView.make(nativeAd: ad, frame: .zero)
    XCTAssertTrue(ad.registeredView === view)
    XCTAssertNotNil(ad.registeredAssets["mediaView"] ?? nil)
    for size in [CGSize(width: 120, height: 213),
                 CGSize(width: 360, height: 640),
                 CGSize(width: 120, height: 213)] {
      view.frame = CGRect(origin: .zero, size: size)
      view.setNeedsLayout()
      view.layoutIfNeeded()
      ad.mediaView?.superview?.layoutIfNeeded()
      XCTAssertEqual(ad.mediaView?.bounds.size, size)
      XCTAssertEqual(ad.mediaView?.superview?.bounds.size, size)
    }
    XCTAssertNil((view as? MediationNativeAdView)?.headlineView)
    XCTAssertNil((view as? MediationNativeAdView)?.bodyView)
    XCTAssertNil((view as? MediationNativeAdView)?.ctaView)
    XCTAssertTrue(view.subviews.contains { ($0 as? UILabel)?.text == "Ad" })
    XCTAssertTrue(ad.overlay.superview === view)
  }

  func testMediaCanMoveToRecreatedPlatformView() {
    let ad = StubNativeAd()
    let oldView = AdsterNativeMediaView.make(nativeAd: ad, frame: .zero)
    let newView = AdsterNativeMediaView.make(
      nativeAd: ad, frame: CGRect(x: 0, y: 0, width: 360, height: 640))
    newView.layoutIfNeeded()
    ad.mediaView?.superview?.layoutIfNeeded()
    XCTAssertFalse(ad.mediaView!.isDescendant(of: oldView))
    XCTAssertTrue(ad.mediaView!.isDescendant(of: newView))
    XCTAssertEqual(ad.mediaView?.bounds.size, newView.bounds.size)
  }
}

private final class StubNativeAd: MediationNativeAd {
  let adType: AdSterAdType = .native
  let sdk: SDK = .adster
  let ttl: Int64 = 60
  let eCPM: Double? = nil
  var eventCallbacks: MediationAdEventCallbacks?
  var eventDelegate: MediationNativeAdEventDelegate?
  let headline: String? = "PVR"
  let body: String? = "PVR"
  let callToAction: String? = "PVR"
  let icon: String? = nil
  let landingUrl: String? = nil
  let openUrlInApp = false
  let starRating: Double? = nil
  let store: String? = nil
  let price: String? = nil
  let advertiser: String? = nil
  let mediaView: UIView? = UIView()
  let aspectRatio: CGFloat? = 360.0 / 640.0
  var overrideImpressionHandling = true
  var overrideClickHandling = true
  weak var registeredView: UIView?
  var registeredAssets: [String: UIView?] = [:]
  let overlay = UIView()

  func registerAdView(_ adView: UIView, clickableAssetViews: [String: UIView?]) {
    registeredView = adView
    registeredAssets = clickableAssetViews
    // Simulate a mediation adapter installing its own overlay at registration.
    adView.addSubview(overlay)
  }
  func recordNativeClick() {}
  func recordNativeImpression() {}
  func destroy() {}
}
