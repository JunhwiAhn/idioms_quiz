// Platform-selective entry point for AdService.
// On web (no dart:io), this resolves to the no-op stub so google_mobile_ads
// is never referenced by the web build. On mobile, the real implementation
// is loaded.
export 'ad_service_stub.dart'
    if (dart.library.io) 'ad_service_mobile.dart';
