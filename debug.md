# Route API Optimization - Fixed Excessive Fetching

## Problem
The app was making **too many route API calls**, causing:
- Excessive network requests
- API rate limiting
- "Requests from this Android client application are blocked" errors
- Poor performance

## Solution Implemented

### 1. Route Caching System
- **Cache Duration**: 10 minutes per route
- **Cache Size**: Maximum 50 cached routes
- **Cache Key**: Based on origin, destination, travel mode, and strategy
- **Automatic Cleanup**: Removes expired entries

### 2. Request Throttling
- **Throttle Delay**: 500ms between API requests
- **Request Deduplication**: Prevents duplicate requests for same route
- **Cancellation**: Newer requests cancel older pending ones

### 3. Widget-Level Debouncing
- **Map Placeholder**: 300ms debounce for route updates
- **Sliding Map**: 400ms debounce for route refresh
- **Timer Management**: Proper cleanup on widget disposal

### 4. Debug Tools
- **Cache Statistics**: View cache size, expiry, pending requests
- **Clear Cache Button**: Manual cache clearing for testing
- **Route Source Tracking**: Shows if route came from cache, API, or geometry

## Files Modified

1. **`routes_service.dart`**
   - Added `_RouteCache` class for caching
   - Added `_RequestThrottler` class for throttling
   - Modified `computeRoute()` to use cache and throttling
   - Added `clearCache()` and `getCacheStats()` methods

2. **`map_placeholder.dart`**
   - Added timer-based debouncing to `_updateRoute()`
   - Split into `_updateRoute()` and `_performRouteUpdate()`
   - Added proper timer disposal

3. **`map.widget.dart`** (sliding_up)
   - Added timer-based debouncing to `_refreshRoutePreview()`
   - Split into `_refreshRoutePreview()` and `_performRouteRefresh()`
   - Added proper timer disposal

4. **`map_debug.dart`**
   - Added cache statistics display
   - Added clear cache button for testing

## Performance Improvements

### Before:
- Multiple API calls per second
- No caching - same routes fetched repeatedly
- No throttling - requests fired immediately
- API rate limiting issues

### After:
- Maximum 1 API call per 500ms
- 10-minute cache for identical routes
- Debounced widget updates (300-400ms)
- Proper request cancellation

## Usage

The optimizations are **automatic** and require no code changes:

```dart
// This will now use caching and throttling automatically
final result = await routesService.computeRoute(
  origin: origin,
  destination: destination,
  apiKey: apiKey,
);
```

## Route Rendering Fix

### 🔧 **New Fallback System**
When Routes API fails (e.g., "blocked" errors), the system now:

1. **Detects API Blocking**: Automatically detects "blocked" responses
2. **Fallback Route Creation**: Creates interpolated polylines between waypoints
3. **Distance Matrix Backup**: Tries Distance Matrix API for accurate distances
4. **Geometry Fallback**: Uses geometric calculations as final fallback

### 🎯 **Improved Route Quality**
- **Interpolated Polylines**: Adds intermediate points every 500m for smoother routes
- **Multiple Data Sources**: Routes API → Distance Matrix → Geometry calculations
- **Better Error Handling**: Graceful degradation instead of failures

## Debug Information

View cache stats in the debug page:
- Cache size and capacity
- Pending request status
- Debug logging status
- Manual cache clearing
- Debug logging toggle

### Debug Controls
```dart
// Enable/disable debug logging
MapRoutesService.setDebugLogging(true);

// Get detailed stats
final stats = MapRoutesService.getCacheStats();

// Clear cache manually
MapRoutesService.clearCache();
```

---

**Original Debug Log:**
Launching lib/main.dart on sdk gphone64 x86 64 in debug mode...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
D/FlutterJNI( 6341): Beginning load of flutter...
D/FlutterJNI( 6341): flutter (null) was loaded normally!
I/flutter ( 6341): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
D/FlutterGeolocator( 6341): Attaching Geolocator to activity
D/FlutterGeolocator( 6341): Creating service.
D/FlutterGeolocator( 6341): Binding to location service.
D/FlutterGeolocator( 6341): Geolocator foreground service connected
D/FlutterGeolocator( 6341): Initializing Geolocator services
D/FlutterGeolocator( 6341): Flutter engine connected. Connected engine count 1
D/WindowLayoutComponentImpl( 6341): Register WindowLayoutInfoListener on Context=com.example.app.MainActivity@98c88e1, of which baseContext=android.app.ContextImpl@b1611b3
Connecting to VM Service at ws://127.0.0.1:43825/TqO4nUKSvr8=/ws
Connected to the VM Service.
[GETX] Instance "GetMaterialController" has been created
[GETX] Instance "GetMaterialController" has been initialized
I/Choreographer( 6341): Skipped 34 frames! The application may be doing too much work on its main thread.
I/Choreographer( 6341): Skipped 52 frames! The application may be doing too much work on its main thread.
I/HWUI ( 6341): Davey! duration=900ms; Flags=1, FrameTimelineVsyncId=1065730, IntendedVsync=45246675678048, Vsync=45247542344680, InputEventId=0, HandleInputStart=45247547159957, AnimationStart=45247547161180, PerformTraversalsStart=45247547162111, DrawStart=45247554039988, FrameDeadline=45246692344714, FrameStartTime=45247546920456, FrameInterval=16666666, WorkloadTarget=16666666, SyncQueued=45247555886602, SyncStart=45247556754754, IssueDrawCommandsStart=45247556993054, SwapBuffers=45247565126249, FrameCompleted=45247577158983, DequeueBufferDuration=9910889, QueueBufferDuration=163232, GpuCompleted=45247575913827, SwapBuffersCompleted=45247577158983, DisplayPresentTime=0, CommandSubmissionCompleted=45247565126249,
D/MapsInitializer( 6341): preferredRenderer: null
D/zzcc ( 6341): preferredRenderer: null
I/zzcc ( 6341): Making Creator dynamically
I/DynamiteModule( 6341): Considering local module com.google.android.gms.maps*core_dynamite:0 and remote module com.google.android.gms.maps_core_dynamite:253425402
I/DynamiteModule( 6341): Selected remote version of com.google.android.gms.maps_core_dynamite, version >= 253425402
V/DynamiteModule( 6341): Dynamite loader version >= 2, using loadModule2NoCrashUtils
I/com.example.app( 6341): AssetManager2(0x734ea9ac36d8) locale list changing from [] to [en-US]
D/zzcc ( 6341): early loading native code
W/NativeHelper( 6341): Loading native library 'gmm-jni' on thread main
D/nativeloader( 6341): Configuring clns-11 for other apk . target_sdk_version=36, uses_libraries=ALL, library_path=/data/user_de/0/com.google.android.gms/app_chimera/m/00000028/dl-MapsCoreDynamite.integ_253425402100800.apk!/lib/x86_64:/data/user_de/0/com.google.android.gms/app_chimera/m/00000028/dl-MapsCoreDynamite.integ_253425402100800.apk!/lib/arm64-v8a, permitted_path=/data:/mnt/expand
D/nativeloader( 6341): Load /data/user_de/0/com.google.android.gms/app_chimera/m/00000028/dl-MapsCoreDynamite.integ_253425402100800.apk!/lib/x86_64/libgmm-jni.so using isolated ns clns-11 (caller=/data/user_de/0/com.google.android.gms/app_chimera/m/00000028/dl-MapsCoreDynamite.integ_253425402100800.apk): ok
I/native ( 6341): I0000 00:00:1759369777.577571 6341 jni_init.cc:30] Initializing JNI...
I/NativeHelper( 6341): JNI initialized.
I/Google Android Maps SDK( 6341): Google Play services client version: 19020000
D/bo ( 6341): SDK type: 1, version: 253425402
D/hp ( 6341): maps_core_dynamite module version in use (0 represents standalone library): 253425402
D/hp ( 6341): Added event: 109
D/hp ( 6341): Added event: 112
D/MapsInitializer( 6341): loadedRenderer: LATEST
D/zzcc ( 6341): preferredRenderer: null
D/bo ( 6341): SDK type: 1, version: 253425402
I/Google Android Maps SDK( 6341): Google Play services package version: 253830038
I/Google Android Maps SDK( 6341): Google Play services maps renderer version(maps_core): 253425402
D/bo ( 6341): SDK type: 1, version: 253425402
D/de ( 6341): about to start loading native library asynchronously
W/x ( 6341): Suppressed StrictMode policy violation: StrictModeDiskReadViolation
I/o ( 6341): Using GMM server: https://clients4.google.com/glm/mmap
W/x ( 6341): Suppressed StrictMode policy violation: StrictModeDiskReadViolation
W/x ( 6341): Suppressed StrictMode policy violation: StrictModeDiskWriteViolation
D/o ( 6341): Using Non-null serverVersionMetadataManager to load previous metadata.
D/o ( 6341): Previous session server version metadata loaded: CggIBhDZv/TGBgoICAMQ+a7zxgYKCggEEPm978YGGAEKCAgBEKC368YG
D/DataRequestDispatcher( 6341): Included server version metadata in dimens
W/x ( 6341): Suppressed StrictMode policy violation: StrictModeDiskReadViolation
W/x ( 6341): Suppressed StrictMode policy violation: StrictModeDiskReadViolation
W/x ( 6341): Suppressed StrictMode policy violation: StrictModeDiskWriteViolation
W/HWUI ( 6341): Image decoding logging dropped!
I/m140.bqt( 6341): getExecutor CREATED bqj@e8ec34b[main]
I/m140.bqt( 6341): getExecutor CREATED ScheduledThreadPoolExecutor@4fe4fe6[Scheduler]
I/m140.bqt( 6341): getExecutor CREATED bqm@e844927[Lite]
I/m140.bqt( 6341): getExecutor CREATED bqm@4cd8d7d[Background]
I/m140.bqt( 6341): getExecutor CREATED bqm@8272fca[Blocking]
I/m140.cco( 6341): marker files=[]
I/m140.bqt( 6341): getExecutor CREATED bqm@cf87de9[TilePrep]
I/m140.box( 6341): Loaded cached client parameters
I/m140.bpk( 6341): finishInitialization ClientParametersManager.
I/m140.boj( 6341): start() account=Account {name=signedout@, type=com.google.android.apps.maps} locale=en_US
I/m140.boj( 6341): P/H: Scheduling next update in 10488.974000 seconds: initial refresh
I/m140.cgm( 6341): FpsProfiler MAIN created on main
I/m140.bqt( 6341): getExecutor CREATED bqm@1c6d05a[Picker]
I/m140.epf( 6341): Found 46 zoom mappings
I/m140.epf( 6341): Zoom tables loaded
W/m140.ffb( 6341): No current context - attempting to create off-screen context
I/m140.ffb( 6341): Created GlConstants: ffa{gpuVendor=Google (NVIDIA Corporation), glVersion=OpenGL ES 3.1 (4.5.0 NVIDIA 580.82.07), glRenderer=Android Emulator OpenGL ES Translator (NVIDIA GeForce RTX 3050 Laptop GPU/PCIe/SSE2), maxTextureSize=32768, maxVertexTextureImageUnits=32, maxVertexUniformVectors=1024, maxSupportedLineWidth=10, maxVertexAttribs=16, nonPowerOfTwoTextureSupport=FULL}
I/m140.dwd( 6341): Map using legacy labeler
I/m140.ewn( 6341): Create or open database: /storage/emulated/0/Android/data/com.example.app/cache/diskcache; secure file path: /data/user/0/com.example.app/app*/testdata
I/m140.duy( 6341): Network fetching: false
I/m140.euz( 6341): Current epoch is now 751
I/m140.duy( 6341): requestDrawingConfig for epoch 751 legend ROADMAP
I/m140.euu( 6341): styleTableCache inserted: 751 ROADMAP https://www.gstatic.com/maps/res/CompactLegend-Roadmap-72e5888136b84547585abeb25a4f76f9
I/m140.ewr( 6341): Database cache size: 1478656 bytes
I/m140.fja( 6341): Model SDK_GPHONE64_X86_64, Product name SDK_GPHONE64_X86_64, Board name GOLDFISH_X86_64, Manufacturer GOOGLE
W/m140.fja( 6341): Model is not recognized, and therefore using default settings.
E/m140.ewr( 6341): Failed to delete expired resources:
E/m140.ewr( 6341): m140.ewk: m140.bbl: Database lock unavailable {canonicalCode=UNAVAILABLE, loggedCode=0, posixErrno=0}
E/m140.ewr( 6341): at com.google.android.libraries.geo.mapcore.internal.store.diskcache.NativeSqliteDiskCacheImpl.flushWrites(:com.google.android.gms.policy_maps_core_dynamite@253425407@253425402032.797495247.797495247:10)
E/m140.ewr( 6341): at m140.ewr.i(:com.google.android.gms.policy_maps_core_dynamite@253425407@253425402032.797495247.797495247:29)
E/m140.ewr( 6341): at m140.ewo.run(:com.google.android.gms.policy_maps_core_dynamite@253425407@253425402032.797495247.797495247:46)
E/m140.ewr( 6341): at m140.hlp.run(:com.google.android.gms.policy_maps_core_dynamite@253425407@253425402032.797495247.797495247:64)
E/m140.ewr( 6341): at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:524)
E/m140.ewr( 6341): 	at m140.bpp$a.run(:com.google.android.gms.policy_maps_core_dynamite@253425407@253425402032.797495247.797495247:23)
E/m140.ewr( 6341): at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1156)
E/m140.ewr( 6341): at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:651)
E/m140.ewr( 6341): at m140.bqe.run(:com.google.android.gms.policy_maps_core_dynamite@253425407@253425402032.797495247.797495247:40)
E/m140.ewr( 6341): at java.lang.Thread.run(Thread.java:1119)
E/m140.ewr( 6341): Caused by: m140.bbl: Database lock unavailable {canonicalCode=UNAVAILABLE, loggedCode=0, posixErrno=0}
E/m140.ewr( 6341): at com.google.android.libraries.geo.mapcore.internal.store.diskcache.NativeSqliteDiskCacheImpl.nativeSqliteDiskCacheFlushWrites(Native Method)
E/m140.ewr( 6341): at com.google.android.libraries.geo.mapcore.internal.store.diskcache.NativeSqliteDiskCacheImpl.flushWrites(:com.google.android.gms.policy_maps_core_dynamite@253425407@253425402032.797495247.797495247:3)
E/m140.ewr( 6341): ... 9 more
I/m140.duy( 6341): Network fetching: true
I/m140.epf( 6341): Found 46 zoom mappings
I/m140.epf( 6341): Zoom tables loaded
I/m140.duy( 6341): requestDrawingConfig for epoch 751 legend ROADMAP
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
I/m140.duy( 6341): requestDrawingConfig for epoch 751 legend ROADMAP
I/PlatformViewsController( 6341): Hosting view in view hierarchy for platform view: 0
I/PlatformViewsController( 6341): PlatformView is using SurfaceProducer backend
I/m140.duy( 6341): Network fetching: true
I/m140.duy( 6341): Network fetching: true
I/m140.duy( 6341): Network fetching: true
I/GoogleMapController( 6341): Installing custom TextureView driven invalidator.
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
I/m140.duy( 6341): Network fetching: true
W/HWUI ( 6341): Image decoding logging dropped!
D/InsetsController( 6341): hide(ime(), fromIme=false)
I/ImeTracker( 6341): com.example.app:4e6bb2dd: onCancelled at PHASE_CLIENT_ALREADY_HIDDEN
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
I/com.example.app( 6341): Compiler allocated 4419KB to compile void m140.efq.c(m140.dmh, m140.eei, m140.egl, m140.enh, boolean)
I/m140.epf( 6341): Found 46 zoom mappings
I/m140.epf( 6341): Zoom tables loaded
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
I/com.example.app( 6341): Compiler allocated 6308KB to compile void m140.ekr.W(m140.epc, m140.fix, android.content.res.Resources, m140.emv, m140.exp, boolean, m140.dls, java.util.Map, boolean, boolean, boolean, boolean)
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
I/com.example.app( 6341): JIT allocated 50KB for compiled code of void m140.ekr.W(m140.epc, m140.fix, android.content.res.Resources, m140.emv, m140.exp, boolean, m140.dls, java.util.Map, boolean, boolean, boolean, boolean)
I/com.example.app( 6341): Compiler allocated 7157KB to compile void m140.ekr.W(m140.epc, m140.fix, android.content.res.Resources, m140.emv, m140.exp, boolean, m140.dls, java.util.Map, boolean, boolean, boolean, boolean)
I/com.example.app( 6341): Compiler allocated 5578KB to compile void m140.esl.o()
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
I/com.example.app( 6341): Compiler allocated 4117KB to compile m140.eoy m140.epc.l(m140.bdl, m140.inv, m140.eoq, byte[], boolean, m140.chg, m140.dgn, java.lang.Iterable)
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
I/m140.bqt( 6341): getExecutor CREATED bqm@8914129[Network]
I/m140.bqt( 6341): getExecutor CREATED bqm@a966386[LocFresh]
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
I/HttpFlagsLoader( 6341): HTTP flags log line (Impl): Using live production flag values from Google
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/JavaCronetEngine( 6341): using the fallback Cronet Engine implementation. Performance will suffer and many HTTP client features, including caching, will not work.
I/m140.caz( 6341): Using Paint server URL: https://www.google.com/maps/vt
I/m140.cam( 6341): PaintParametersListeningServerChannelManager got a client parameters update event.
I/m140.bvx( 6341): Updating the server URL. Old URL: https://www.google.com/maps/vt New URL: https://www.google.com/maps/vt
I/m140.bvx( 6341): Creating a new server channel with URL: https://www.google.com/maps/vt, server channel factory class: class m140.bvu
I/m140.cdc( 6341): Initial labeling completed.
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/DynamiteModule( 6341): Local module descriptor class for com.google.android.gms.googlecertificates not found.
I/DynamiteModule( 6341): Considering local module com.google.android.gms.googlecertificates:0 and remote module com.google.android.gms.googlecertificates:7
I/DynamiteModule( 6341): Selected remote version of com.google.android.gms.googlecertificates, version >= 7
W/com.example.app( 6341): ClassLoaderContext classpath element checksum mismatch. expected=1205438932, found=3087821963 (DLC[];PCL[base.apk*1205438932]{PCL[/system/framework/org.apache.http.legacy.jar*4247870504]#PCL[/system/framework/com.android.media.remotedisplay.jar*487574312]#PCL[/system/framework/com.android.location.provider.jar*1570284764]#PCL[/system_ext/framework/androidx.window.extensions.jar*1030441313]#PCL[/system_ext/framework/androidx.window.sidecar.jar*3860983653]} | DLC[];PCL[/data/app/~~XKwW6iCCEPfXT9IYow2_Xw==/com.example.app-Dcuc6Z-wiX_kzQ3P14bBlQ==/base.apk*3087821963]{PCL[/system_ext/framework/androidx.window.extensions.jar*1030441313]#PCL[/system_ext/framework/androidx.window.sidecar.jar*3860983653]#PCL[/system/framework/org.apache.http.legacy.jar*4247870504]})
I/com.example.app( 6341): AssetManager2(0x734ea9ad5978) locale list changing from [] to [en-US]
I/com.example.app( 6341): AssetManager2(0x734ea9ae3118) locale list changing from [] to [en-US]
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
D/ProfileInstaller( 6341): Installing profile for com.example.app
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/ImageReader_JNI( 6341): Unable to acquire a buffer item, very likely client tried to acquire more than maxImages buffers
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
W/HWUI ( 6341): Image decoding logging dropped!
Application finished.

Exited.
