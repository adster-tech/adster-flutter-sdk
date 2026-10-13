import UIKit
import AdsFramework

/// The Flutter builder owns the headline, body and CTA. Its platform view is
/// only the media slot, which must follow Flutter's layout (including PIP).
enum AdsterNativeMediaView {
    static func make(nativeAd: AdsFramework.MediationNativeAd, frame: CGRect) -> UIView {
        let adView = MediationNativeAdView()
        adView.frame = frame
        adView.clipsToBounds = true

        let mediaContainer = UIView()
        mediaContainer.clipsToBounds = true
        pin(mediaContainer, to: adView)
        adView.mediaView = mediaContainer

        // Keep the registered native wrapper for network click/impression
        // handling and any network-provided overlays such as AdChoices.
        adView.setNativeAd(nativeAd: nativeAd)
        if let mediaView = nativeAd.mediaView {
            mediaView.removeFromSuperview()
            pin(mediaView, to: mediaContainer)
        }

        // Attribution overlays the media without reserving space for a second
        // native card alongside the publisher's Flutter layout.
        let badge = UILabel()
        badge.text = "Ad"
        badge.font = .systemFont(ofSize: 11, weight: .semibold)
        badge.textColor = .white
        badge.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        badge.textAlignment = .center
        badge.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 4),
            badge.topAnchor.constraint(equalTo: adView.topAnchor, constant: 4),
            badge.widthAnchor.constraint(equalToConstant: 28),
            badge.heightAnchor.constraint(equalToConstant: 18)
        ])
        return adView
    }

    private static func pin(_ child: UIView, to parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }
}
