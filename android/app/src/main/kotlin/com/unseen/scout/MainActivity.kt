package com.unseen.scout

// flutter_mapbox_navigation_plus requires FlutterFragmentActivity instead of
// FlutterActivity to avoid ViewModel lifecycle errors during navigation.
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
