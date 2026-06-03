import SwiftUI
import WebKit

/// Plays the transparent WebM mascot from the app bundle.
struct MascotVideoView: UIViewRepresentable {
    let resourceName: String
    var fileExtension: String = "webm"

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            return webView
        }

        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("lifeos-mascot-player", isDirectory: true)
        try? FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)

        let temporaryVideoURL = temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        if !FileManager.default.fileExists(atPath: temporaryVideoURL.path) {
            try? FileManager.default.copyItem(at: url, to: temporaryVideoURL)
        }

        let html = """
        <!doctype html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            html, body {
              margin: 0;
              width: 100%;
              height: 100%;
              overflow: hidden;
              background: transparent;
            }
            video {
              width: 100%;
              height: 100%;
              object-fit: contain;
              background: transparent;
              pointer-events: auto;
              -webkit-transform: translateZ(0);
            }
          </style>
        </head>
        <body>
          <video id="mascot" src="\(temporaryVideoURL.lastPathComponent)" autoplay muted loop playsinline webkit-playsinline preload="auto"></video>
          <script>
            const video = document.getElementById('mascot');
            function startMuted() {
              video.muted = true;
              video.play().catch(function() {});
            }
            video.addEventListener('canplay', startMuted);
            window.addEventListener('load', startMuted);
            document.body.addEventListener('click', function() {
              video.muted = false;
              video.volume = 1;
              video.play().catch(function() {});
            });
          </script>
        </body>
        </html>
        """

        let htmlURL = temporaryDirectory.appendingPathComponent("\(resourceName)-player.html")
        try? html.write(to: htmlURL, atomically: true, encoding: .utf8)
        webView.loadFileURL(htmlURL, allowingReadAccessTo: temporaryDirectory)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
