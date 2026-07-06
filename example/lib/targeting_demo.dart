/// Shared demo values for predefined custom targeting and the publisher
/// provided identifier (PPID).
///
/// These are passed to every ad request in this example to show how targeting
/// works across all ad formats. Targeting is honoured only for GAM-served
/// demand — other networks simply ignore it.
///
/// Replace these with values derived from your own app/user context.
const Map<String, String> kDemoCustomTargetArgs = <String, String>{
  'content_category': 'sports',
  'user_tier': 'premium',
};

/// Publisher provided identifier (PPID) forwarded to GAM with each request.
const String kDemoPublisherProvidedId = 'demo-ppid-12345';
