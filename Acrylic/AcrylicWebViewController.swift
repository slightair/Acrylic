import Cocoa
import WebKit

final class AcrylicWebViewController: NSViewController {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: URL(string: "https://w0sd0.csb.app/")!)
        webView.load(request)
        webView.navigationDelegate = self
        webView.setValue(false, forKey: "drawsBackground")
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        transparentizeWindow()
    }

    private func transparentizeWindow() {
        let window = view.window
        window?.backgroundColor = .clear
        window?.isOpaque = false
        window?.hasShadow = false
        window?.isMovableByWindowBackground = true
        window?.level = .screenSaver
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
}

extension AcrylicWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("done")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
}
