//
//  YouTubeWebView.swift
//  Runner
//
//  Created by Akshay N on 02/09/24.
//

import SwiftUI
import WebKit

struct YouTubeWebView: View {
    let videoURL: URL
    let videoTitle: String
    let videoDescription: String
    @State private var isLoading = true
    var body: some View{
        ZStack{
            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]), // Adjust the colors as needed
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .edgesIgnoringSafeArea(.all) //
        VStack {
            
            ZStack{
                
                if isLoading {
                    
                    ProgressView() // Activity indicator while loading
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(2)
                    
                }
                WebView(url: videoURL,
                        jsCode: """
var myyoutubelogo = document.getElementsByClassName("ytp-large-play-button ytp-button ytp-large-play-button-red-bg");
for (var i = 0; i < myyoutubelogo.length; i++) {
    myyoutubelogo[i].style.display = 'none';
}

var myyoutube = document.getElementsByClassName("ytp-youtube-button ytp-button yt-uix-sessionlink");
for (var i = 0; i < myyoutube.length; i++) {
    myyoutube[i].style.display = 'none';
}

var title = document.getElementsByClassName("ytp-chrome-top ytp-show-cards-title");
for (var i = 0; i < title.length; i++) {
    title[i].style.display = 'none';
}

var endscreen = document.getElementsByClassName("html5-endscreen ytp-player-content videowall-endscreen ytp-endscreen-paginate ytp-show-tiles");
for (var i = 0; i < endscreen.length; i++) {
    endscreen[i].style.display = 'none';
}

var logo = document.getElementsByClassName("annotation annotation-type-custom iv-branding");
for (var i = 0; i < logo.length; i++) {
    logo[i].style.display = 'none';
}

var video = document.querySelector('video');

video.addEventListener('play', function() {
    var checkElements = setInterval(function() {
        var myyoutube = document.getElementsByClassName("ytp-menuitem");
        if (myyoutube.length >= 6) {
            myyoutube[5].style.display = 'none';
            clearInterval(checkElements);
        }

        var sub = document.getElementsByClassName("branding-img-container ytp-button");
        for (var i = 0; i < sub.length; i++) {
            sub[i].style.display = 'none';
        }
    }, 500);

    var checkRelatedVideos = setInterval(function() {
        var relatedVideos = document.getElementsByClassName("ytp-endscreen-content");

        if (relatedVideos.length > 0) {
            for (var i = 0; i < relatedVideos.length; i++) {
                relatedVideos[i].style.display = 'none';
            }
            clearInterval(checkRelatedVideos);
        }
    }, 500);

    var checkButtons = setInterval(function() {
        var previousButton = document.getElementsByClassName("ytp-button ytp-endscreen-previous");

        if (previousButton.length > 0) {
            for (var i = 0; i < previousButton.length; i++) {
                previousButton[i].style.display = 'none';
            }
            clearInterval(checkButtons);
        }

        var nextButton = document.getElementsByClassName("ytp-button ytp-endscreen-next");

        if (nextButton.length > 0) {
            for (var i = 0; i < nextButton.length; i++) {
                nextButton[i].style.display = 'none';
            }
            clearInterval(checkButtons);
        }
    }, 500);
});
""", isLoading: $isLoading
                        
                )
                .aspectRatio(16/9, contentMode: .fit)
                
            }
            ScrollView() {
                VStack(alignment: .leading) {
                    Text(videoTitle)
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .font(.title2)
                    
                    Divider().padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    
                    //                    Text("Description:")
                    //                        .fontWeight(.semibold)
                    //                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                    
                    Text(videoDescription)
                        .padding(EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 16))
                        .foregroundColor(.gray)
                        .font(.callout)
                    
                    
                }
            }
        }
        }
        
        
    }
    private func dismissView() {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.dismiss(animated: true, completion: nil)
        }
    }
    
}

#Preview {
    YouTubeWebView(videoURL: URL(string: "https://www.youtube.com/embed/A3s07JYA48o")!, videoTitle: "Smaple title", videoDescription: "Hello description")
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
    
}

struct WebView: UIViewRepresentable {
    let url: URL
    let jsCode: String
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject JavaScript code after the page has loaded
            webView.evaluateJavaScript(parent.jsCode, completionHandler: { result, error in
                if let error = error {
                    print("JavaScript injection failed: \(error)")
                } else {
                    print("JavaScript injected successfully")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.parent.isLoading = true
                    }
                }
            })
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
