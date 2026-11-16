// SPDX-License-Identifier: GPL-3.0-only
// RespringViewController.swift — Respring v1.2
//
// Harness WKWebView cho kỹ thuật NeoSpring (WebKit GPU process respring).
//
// Nguồn và credit:
// - Kỹ thuật gốc (WebKit GPU process respring): @neonmodder123
// - Swift implementation: @skadz108
// - Dự án NeoSpring: @rooootdev — https://github.com/rooootdev/neospring
// - Bản thích ứng tham chiếu: GestaltX, file GestaltX/NeoSpringView.swift,
//   GPL-3.0 — https://github.com/huamidev/GestaltX (xem THIRD_PARTY_NOTICES.md).
//
// Payload HTML/JS thật của NeoSpring (định nghĩa window.startNeoSpring() /
// window.stopNeoSpring()) nằm trong file bundle `NeoSpringPayload.html` —
// file này KHÔNG chứa payload gây crash, và KHÔNG bị sửa đổi ở đây.
//
// Tối ưu tốc độ — bấm icon là respring nhanh nhất có thể:
// 1. Không chờ gì ở phía native: vừa load HTML là payload TỰ GỌI
//    window.startNeoSpring() ngay trong lúc parse (script chèn cuối trang),
//    không chờ didFinish, không chờ viewDidAppear, không evaluateJavaScript
//    từ native. startNeoSpring() tự chờ 2 nhịp requestAnimationFrame rồi
//    mới nạp iframe chứa payload — 2 nhịp này là bắt buộc để GPU compositor
//    chạy, trên iPhone 17 Pro Max 120Hz chỉ ~17ms.
// 2. WKWebView tạo trong viewDidLoad, load ngay — WebContent process spawn
//    song song với lúc window hiện lên.
// 3. didFinish chỉ là lưới an toàn: nếu auto-start chưa chạy thì gọi lại
//    (startNeoSpring có cờ started nên gọi 2 lần cũng chỉ chạy 1 lần).
// 4. Không SwiftUI, không delay, không animation chuyển màn, không UI.
//    Hiệu ứng zoom khi mở app là của iOS, app không tắt được — nhưng với
//    v1.2 thì respring nổ ra NGAY TRONG lúc animation đang chạy, thay vì
//    chờ animation chạy xong mới nổ như v1.0/v1.1.

import UIKit
import WebKit

final class RespringViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        // Non-persistent: không để lại dữ liệu web sau lần chạy (theo GestaltX).
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        self.webView = webView

        webView.loadHTMLString(Self.autoStartHTML, baseURL: nil)
    }

    // Lưới an toàn: nếu auto-start trong HTML chưa chạy thì gọi lại ở đây.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("typeof window.startNeoSpring === 'function' && window.startNeoSpring()", completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.loadHTMLString(Self.autoStartHTML, baseURL: nil)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.loadHTMLString(Self.autoStartHTML, baseURL: nil)
    }

    /// Payload + script tự chạy ngay khi parse xong: không chờ native gọi.
    private static var autoStartHTML: String {
        let html = payloadHTML
        let autoStart = "<script>window.startNeoSpring()</script>"
        if html.contains("</body>") {
            return html.replacingOccurrences(of: "</body>", with: autoStart + "</body>")
        }
        return html + autoStart
    }

    private static var payloadHTML: String {
        if let url = Bundle.main.url(forResource: "NeoSpringPayload", withExtension: "html"),
           let html = try? String(contentsOf: url, encoding: .utf8),
           !html.isEmpty {
            return html
        }
        return "<!DOCTYPE html><html><body style='background:#000'></body></html>"
    }
}
