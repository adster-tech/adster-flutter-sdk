import Flutter
import AdsFramework

class AdsterNativeAdView: NSObject, FlutterPlatformView{
    
    private var _view: UIView
    private let label = UILabel()
    
    private var widgetId: String?
    private var controller: UIViewController
    private var adBridge: AdsterNativeAdBridge
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, adBridge: AdsterNativeAdBridge) {
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
                if let nativeAd =  adBridge.getNativeAd(widgetId: widgetId!){
                    print("LandingURL: \(nativeAd.mediaView()?.landingUrl ?? "nil")")
                    nativeAd.mediaView()?.eventDelegate = self
                    if let mediationNativeAd = nativeAd.mediaView() {
                        self._view = createNativeAdView(nativeAd: mediationNativeAd)
                        nativeAd.setMediaViewByAd(mediaView: self._view)
                    }
                }
            }
        }
    }

    private func createNativeAdView(nativeAd: AdsFramework.MediationNativeAd) -> UIView {
        let adView = MediationNativeAdView()
        adView.backgroundColor = UIColor.clear
        adView.layer.borderWidth = 1
        adView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
        adView.layer.cornerRadius = 8
        adView.clipsToBounds = true

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(contentView)

        let mediaContainer = UIView()
        mediaContainer.translatesAutoresizingMaskIntoConstraints = false
        mediaContainer.clipsToBounds = true
        mediaContainer.layer.cornerRadius = 6

        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.text = "Ad"
        labelView.font = .systemFont(ofSize: 11, weight: .medium)
        labelView.textColor = .systemBlue

        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        headlineLabel.numberOfLines = 2

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = nativeAd.body
        bodyLabel.font = .systemFont(ofSize: 13)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 2

        let ctaButton = UIButton(type: .system)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        ctaButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        ctaButton.backgroundColor = .systemBlue
        ctaButton.tintColor = .white
        ctaButton.layer.cornerRadius = 8
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
        ctaButton.isUserInteractionEnabled = false

        let textStack = UIStackView(arrangedSubviews: [labelView, headlineLabel, bodyLabel, ctaButton])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 6

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
            ctaButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 34)
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

extension AdsterNativeAdView: MediationNativeAdEventDelegate {
    func recordNativeClick() {
        print("Ad clicked")
        adBridge.adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId])
    }

    func recordNativeImpression() {
        print("Ad impression recorded")
        adBridge.adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId])
    }
}
