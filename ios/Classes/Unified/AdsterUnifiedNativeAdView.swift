import Flutter
import AdsFramework

class AdsterUnifiedNativeAdView: NSObject, FlutterPlatformView{
    
    private var _view: UIView
    private let label = UILabel()
    
    private var widgetId: String?
    private var controller: UIViewController
    private var adBridge: AdsterUnifiedAdBridge
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, adBridge: AdsterUnifiedAdBridge) {
        let view = UIView(frame: frame)
        view.backgroundColor = .lightGray // placeholder
        self._view = view
        self.adBridge = adBridge
        label.text = "Natively not loaded"
        label.textAlignment = .center
        label.frame = _view.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.controller = UIApplication.shared.windows.first!.rootViewController!
        super.init()
        if let argsMap = args as? [String: Any] {
            self.widgetId = argsMap["widgetId"] as? String
            if self.widgetId != nil {
                if let nativeAd =  adBridge.getUnifiedAd(widgetId: widgetId!){
                    print("LandingURL: \(nativeAd.nativeAd()?.landingUrl ?? "nil")")
                    nativeAd.nativeAd()?.eventDelegate = self
                    if let mediationNativeAd = nativeAd.nativeAd() {
                        self._view = createNativeAdView(nativeAd: mediationNativeAd)
                        nativeAd.setMediaViewByAd(mediaView: self._view)
                    }
                }
            }
        }
    }

    private func createNativeAdView(nativeAd: AdsFramework.MediationNativeAd) -> UIView {
        let adView = MediationNativeAdView()
        adView.backgroundColor = UIColor(red: 0.015, green: 0.022, blue: 0.035, alpha: 1)
        adView.layer.borderWidth = 1
        adView.layer.borderColor = UIColor(red: 0.0, green: 0.62, blue: 0.95, alpha: 0.75).cgColor
        adView.layer.cornerRadius = 8
        adView.clipsToBounds = true

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(contentView)

        let mediaContainer = UIView()
        mediaContainer.translatesAutoresizingMaskIntoConstraints = false
        mediaContainer.clipsToBounds = true
        mediaContainer.layer.cornerRadius = 6
        mediaContainer.backgroundColor = UIColor.black.withAlphaComponent(0.35)

        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.text = "Ad"
        labelView.font = .systemFont(ofSize: 11, weight: .semibold)
        labelView.textColor = UIColor(red: 0.30, green: 0.86, blue: 1.0, alpha: 1)
        labelView.backgroundColor = UIColor(red: 0.0, green: 0.42, blue: 0.70, alpha: 0.22)
        labelView.layer.cornerRadius = 4
        labelView.clipsToBounds = true
        labelView.textAlignment = .center

        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        headlineLabel.textColor = UIColor.white
        headlineLabel.numberOfLines = 2

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = nativeAd.body
        bodyLabel.font = .systemFont(ofSize: 13, weight: .regular)
        bodyLabel.textColor = UIColor(red: 0.78, green: 0.84, blue: 0.92, alpha: 1)
        bodyLabel.numberOfLines = 2

        let ctaButton = UIButton(type: .system)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        ctaButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        ctaButton.backgroundColor = UIColor(red: 0.0, green: 0.52, blue: 1.0, alpha: 1)
        ctaButton.tintColor = UIColor.white
        ctaButton.layer.cornerRadius = 10
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        ctaButton.isUserInteractionEnabled = false

        let textStack = UIStackView(arrangedSubviews: [labelView, headlineLabel, bodyLabel, ctaButton])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 7

        contentView.addSubview(mediaContainer)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            contentView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            contentView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            contentView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),

            mediaContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mediaContainer.widthAnchor.constraint(equalToConstant: 132),
            mediaContainer.heightAnchor.constraint(equalToConstant: 132),

            textStack.leadingAnchor.constraint(equalTo: mediaContainer.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            labelView.widthAnchor.constraint(equalToConstant: 28),
            labelView.heightAnchor.constraint(equalToConstant: 18),
            ctaButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 38)
        ])

        adView.bodyView = bodyLabel
        adView.headlineView = headlineLabel
        adView.ctaView = ctaButton
        adView.mediaView = mediaContainer

        adView.setNativeAd(nativeAd: nativeAd)

        if let mediaView = nativeAd.mediaView {
            addMediaViewToParentView(childView: mediaView, parentView: mediaContainer)
        }

        return adView
    }
    
    func addMediaViewToParentView(childView: UIView, parentView: UIView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(childView)
        
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            childView.topAnchor.constraint(equalTo: parentView.topAnchor),
            childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }
    
    func view() -> UIView {
        return _view
    }
}

extension AdsterUnifiedNativeAdView: MediationNativeAdEventDelegate {
    func recordNativeClick() {
        print("Ad clicked")
        adBridge.adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId])
    }

    func recordNativeImpression() {
        print("Ad impression recorded")
        adBridge.adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId])
    }
}
