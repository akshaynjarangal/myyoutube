import Flutter
import SwiftUI
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let swiftUIChannel = FlutterMethodChannel(name: "com.akshay",
                                                  binaryMessenger: controller.binaryMessenger)
        swiftUIChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "loadUrl" {
                let arguments = call.arguments as? [String:Any]
                let url = arguments?["url"] as? String
                let videoTitle = arguments?["title"] as? String
                let videoDesc = arguments?["desc"] as? String
                self.openVideoPlayerInsSwiftUI(videoLink: url ?? "", title: videoTitle ?? "", description: videoDesc ?? "")
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func openVideoPlayerInsSwiftUI(videoLink:String,title :String,description: String) {
        let videoURL = URL(string: videoLink)!
        let videoTitle = title
        let videoDescription = description
        
        let swiftView = YouTubeWebView(videoURL: videoURL, videoTitle: videoTitle, videoDescription: videoDescription)
        let navController = UIHostingController(rootView: swiftView)
        let pageview = UINavigationController(rootViewController: navController)
        
        // Add close button
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeNativeScreen))
        navController.navigationItem.rightBarButtonItem = closeButton
        
        pageview.modalPresentationStyle = .fullScreen
        self.window.rootViewController?.present(pageview, animated: true, completion: nil)
    }
    
    @objc private func closeNativeScreen() {
        self.window.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
