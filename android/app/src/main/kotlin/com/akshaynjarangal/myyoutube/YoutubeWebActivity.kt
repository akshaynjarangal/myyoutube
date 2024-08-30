package com.akshaynjarangal.myyoutube
import android.annotation.SuppressLint
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.os.Handler
import android.util.TypedValue
import android.view.View
import android.view.WindowManager
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import android.widget.ProgressBar
import android.widget.RelativeLayout
import androidx.appcompat.app.AppCompatActivity

class YoutubeWebActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private lateinit var progressBar: ProgressBar
    private lateinit var fullscreenContainer: FrameLayout
    private lateinit var mainLayout: RelativeLayout
    private var customView: View? = null

    @SuppressLint("SetJavaScriptEnabled", "MissingInflatedId")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_youtube)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        webView = findViewById(R.id.webView)
        progressBar = findViewById(R.id.loadingIndicator)
        fullscreenContainer = findViewById(R.id.fullscreen_container)
        mainLayout = findViewById(R.id.mainlayout)
        val videoTitle = intent.getStringExtra("title")

        setTitle(videoTitle)
        webView.visibility = View.GONE

        // Enable JavaScript
        webView.settings.javaScriptEnabled = true

        // Load YouTube iframe

        val url = intent.getStringExtra("url")
        if (url != null) {
            webView.loadUrl(url)
        }

        // Set WebViewClient to handle page loading and inject JavaScript
        webView.webViewClient = object : WebViewClient() {
            override fun onPageCommitVisible(view: WebView?, url: String?) {
                super.onPageCommitVisible(view, url)
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                // Inject JavaScript to hide elements
                val jsCode = """
                    var fullscreenButton = document.getElementsByClassName("ytp-fullscreen-button ytp-button")
        for (var i=0 ; i<fullscreenButton.length ; i++){fullscreenButton[i].style.display = 'none';}
                   var myyoutubelogo = document.getElementsByClassName("ytp-large-play-button ytp-button ytp-large-play-button-red-bg")
        for (var i=0 ; i<myyoutubelogo.length ; i++){myyoutubelogo[i].style.display = 'none';}
                var myyoutube = document.getElementsByClassName("ytp-youtube-button ytp-button yt-uix-sessionlink")
        for (var i=0 ; i<myyoutube.length ; i++){myyoutube[i].style.display = 'none';}
        
        var title = document.getElementsByClassName("ytp-chrome-top ytp-show-cards-title")
        for (var i=0 ; i<title.length ; i++){title[i].style.display = 'none';}
        var endscreen = document.getElementsByClassName("html5-endscreen ytp-player-content videowall-endscreen ytp-endscreen-paginate ytp-show-tiles")
        for (var i=0 ; i<endscreen.length ; i++){endscreen[i].style.display = 'none';}
        var logo = document.getElementsByClassName("annotation annotation-type-custom iv-branding")
        for (var i=0 ; i<logo.length ; i++){logo[i].style.display = 'none';}
        
        var video = document.querySelector('video');

video.addEventListener('play', function() {
    var checkElements = setInterval(function() {
        var myyoutube = document.getElementsByClassName("ytp-menuitem");
        if (myyoutube.length >= 6) { 
            myyoutube[5].style.display = 'none'; 
            clearInterval(checkElements); 
        }
        
        var sub = document.getElementsByClassName("branding-img-container ytp-button")
        for (var i=0 ; i<sub.length ; i++){sub[i].style.display = 'none';}
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

        """

                view?.evaluateJavascript(jsCode) { result ->
                    print("--------><---------- $result")
                }

                // Remove the progress bar after a delay of 2 seconds
                Handler().postDelayed({
                    progressBar.visibility = View.GONE
                    webView.visibility = View.VISIBLE
                }, 2000)
            }

            override fun shouldOverrideUrlLoading(
                view: WebView?,
                request: WebResourceRequest?
            ): Boolean {
                return false // Keep loading the current WebView
            }
        }
        webView.webChromeClient = object : WebChromeClient() {

            override fun onShowCustomView(view: View?, callback: WebChromeClient.CustomViewCallback?) {
                if (customView != null) {
                    callback?.onCustomViewHidden()
                    return
                }
                // Enter fullscreen
                fullscreenContainer.addView(view)
                customView = view
                fullscreenContainer.visibility = View.VISIBLE
                mainLayout.layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT
                webView.visibility = View.GONE
                supportActionBar?.hide()
                window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
                window.decorView.systemUiVisibility = (
                        View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                                or View.SYSTEM_UI_FLAG_FULLSCREEN)
            }

            override fun onHideCustomView() {
                // Exit fullscreen
                if (customView == null) return

                fullscreenContainer.removeView(customView)
                customView = null
                fullscreenContainer.visibility = View.GONE
                val heightInDp = 250
                val heightInPixels = TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP,
                    heightInDp.toFloat(),
                    resources.displayMetrics
                ).toInt()
                mainLayout.layoutParams.height = heightInPixels
                webView.visibility = View.VISIBLE
                supportActionBar?.show()
                window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
            }
        }

    }

    override fun onSupportNavigateUp(): Boolean {
        onBackPressed()
        return true
    }
}
