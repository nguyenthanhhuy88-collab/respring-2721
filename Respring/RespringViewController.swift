// SPDX-License-Identifier: GPL-3.0-only
// RespringViewController.swift — Respring v1.3
//
// Harness WKWebView cho kỹ thuật NeoSpring (WebKit GPU process respring).
//
// Nguồn và credit:
// - Kỹ thuật gốc (WebKit GPU process respring): @neonmodder123
// - Swift implementation: @skadz108
// - Dự án NeoSpring: @rooootdev — https://github.com/rooootdev/neospring
// - Bản thích ứng tham chiếu (cấu trúc harness, chờ view có kích thước thật
//   rồi mới start): GestaltX, file GestaltX/NeoSpringView.swift, GPL-3.0 —
//   https://github.com/huamidev/GestaltX (xem THIRD_PARTY_NOTICES.md).
//
// Payload HTML/JS thật của NeoSpring (định nghĩa window.startNeoSpring() /
// window.stopNeoSpring()) nằm trong file bundle `NeoSpringPayload.html` —
// file này KHÔNG chứa payload gây crash.
//
// V1.3 — QUAY LẠI CÒ TRIGGER ĐÃ CHỨNG MINH CHẠY ĐƯỢC (v1.0/v1.1):
// v1.2 cho payload tự chạy trong lúc parse đã HỎNG — mở app chỉ đen thui,
// không respring. Nguyên nhân: startNeoSpring() chờ 2 nhịp
// requestAnimationFrame mới nạp iframe, mà rAF chỉ tick khi trang đã được
// vẽ lên màn hình thật; gọi trong lúc parse (trang chưa vẽ lần nào) thì
// rAF không tick, iframe không bao giờ nạp, không có gì xảy ra. Bài học:
// KHÔNG tự chạy trong lúc parse — phải chờ trang load xong VÀ view đã hiện
// (window != nil, bounds > 0) rồi mới gọi, đúng như GestaltX.
// Khác v1.1 ở 2 chỗ: gộp 2 lần evaluateJavaScript thành 1 lần duy nhất,
// và thử start ngay ở viewDidLayoutSubviews (sớm hơn viewDidAppear 1 nhịp).
// Không SwiftUI, không delay, không animation chuyển màn, không UI.

import UIKit
import WebKit
import QuartzCore

final class RespringViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var pageLoaded = false
    private var viewAppeared = false
    private var startRequested = false

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

        webView.loadHTMLString(Self.payloadHTML, baseURL: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewAppeared = true
        startIfReady()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startIfReady()
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageLoaded = true
        startIfReady()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Trang local gần như không lỗi; thử load lại 1 lần.
        if !startRequested {
            webView.loadHTMLString(Self.payloadHTML, baseURL: nil)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if !startRequested {
            webView.loadHTMLString(Self.payloadHTML, baseURL: nil)
        }
    }

    // MARK: - Start

    private func startIfReady() {
        guard pageLoaded, viewAppeared, !startRequested,
              let webView, webView.window != nil,
              webView.bounds.width > 0, webView.bounds.height > 0 else { return }
        startRequested = true
        webView.setNeedsLayout()
        webView.layoutIfNeeded()
        CATransaction.flush()
        // 1 lần evaluateJavaScript duy nhất: kiểm tra + start trong cùng 1 lượt.
        webView.evaluateJavaScript(
            "typeof window.startNeoSpring === 'function' ? (window.startNeoSpring(), 'started') : 'missing'"
        ) { _, _ in
            // Không có callback thành công: nếu chạy đúng thì SpringBoard đã
            // restart rồi. Nếu không, app cứ đen — mở lại là thử lại.
        }
    }

    // MARK: - Payload

    private static var payloadHTML: String {
        if let url = Bundle.main.url(forResource: "NeoSpringPayload", withExtension: "html"),
           let html = try? String(contentsOf: url, encoding: .utf8),
           !html.isEmpty {
            return html
        }
        return "<!DOCTYPE html><html><body style='background:#000'></body></html>"
    }
}
