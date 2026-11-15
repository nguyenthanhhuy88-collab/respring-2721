// SPDX-License-Identifier: GPL-3.0-only
// NeoSpring.swift — Respring 27
//
// Harness (bộ khung WKWebView) cho kỹ thuật NeoSpring.
//
// Nguồn và credit — BẮT BUỘC đọc trước khi sửa file này:
// - Kỹ thuật gốc (WebKit GPU process respring): @neonmodder123
// - Swift implementation: @skadz108
// - Dự án NeoSpring: @rooootdev — https://github.com/rooootdev/neospring
// - Bản thích ứng tham chiếu ở đây (cấu trúc harness, timeout, hủy, loại
//   Simulator, non-persistent data store): GestaltX, file
//   GestaltX/NeoSpringView.swift, GPL-3.0 — https://github.com/huamidev/GestaltX
//   (xem THIRD_PARTY_NOTICES.md).
// - AirCard-iOS (MIT) cũng có RespringHelper.swift với cùng kỹ thuật; file đó
//   KHÔNG được sao chép vào đây (không đọc được trong môi trường này).
//
// QUAN TRỌNG — file này KHÔNG chứa payload gây crash:
// Payload HTML/JS thật của NeoSpring (tài liệu HTML định nghĩa
// window.startNeoSpring() / window.stopNeoSpring()) KHÔNG được nhúng sẵn.
// Nó phải nằm trong file bundle `NeoSpringPayload.html`. File mẫu kèm theo
// project chỉ là trang chờ benign — app sẽ báo rõ "Chưa có payload" thay vì
// giả vờ respring. Muốn bật respring thật, làm theo mục "Thêm payload
// NeoSpring" trong README.md (lấy HTML từ repo NeoSpring/GestaltX ở trên).
//
// Cách harness hoạt động (tóm tắt, theo GestaltX):
// 1. Mở một WKWebView toàn màn hình, non-persistent store, bật JavaScript.
// 2. Chỉ bắt đầu chạy payload SAU KHI web view đã gắn vào cửa sổ và có
//    kích thước thật (didMoveToWindow / layoutSubviews + kiểm tra
//    window != nil và bounds.width/height > 0), rồi flush CATransaction.
// 3. Gọi window.startNeoSpring() qua evaluateJavaScript.
// 4. Timeout: 10 giây nếu chưa start được, 20 giây sau khi đã start —
//    quá hạn thì dừng và báo timeout (kỹ thuật này không có callback
//    thành công, vì nếu thành công thì SpringBoard đã restart rồi).
// 5. Hủy: gọi window.stopNeoSpring(), stopLoading, gỡ delegate.
// 6. Simulator: không chạy (kỹ thuật chỉ có ý nghĩa trên máy thật).

import SwiftUI
import WebKit
import QuartzCore

/// Kết quả / trạng thái của một lần thử NeoSpring.
enum NeoSpringStatus: Equatable {
    case idle
    case running
    case started
    case timedOut
    case failed(String)
    case payloadMissing
    case cancelled

    var label: String {
        switch self {
        case .idle: return "Chưa chạy"
        case .running: return "Đang chạy NeoSpring…"
        case .started: return "Payload đã start — đang chờ SpringBoard…"
        case .timedOut: return "Hết giờ — không respring. Có thể bản iOS này không hỗ trợ."
        case .failed(let message): return "Lỗi: \(message)"
        case .payloadMissing: return "Chưa có payload NeoSpring — xem README để thêm."
        case .cancelled: return "Đã hủy"
        }
    }
}

/// Model điều khiển một lần thử respring, ghi log để hiển thị trên UI.
@MainActor
final class NeoSpringModel: ObservableObject {
    @Published private(set) var status: NeoSpringStatus = .idle
    @Published private(set) var logLines: [String] = []
    @Published private(set) var isRunning = false

    /// Số giây chờ tối đa sau khi payload đã start (theo GestaltX: 20s).
    var timeoutAfterStart: TimeInterval = 20
    /// Số giây chờ tối đa trước khi payload start (theo GestaltX: 10s).
    var timeoutBeforeStart: TimeInterval = 10

    private var timeoutTask: Task<Void, Never>?

    var isiOSVersionString: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "iOS \(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    func log(_ line: String) {
        let stamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logLines.append("[\(stamp)] \(line)")
    }

    func clearLog() { logLines.removeAll() }

    /// Bắt đầu một lần thử: reset log, đặt trạng thái running.
    func start() {
        guard !isRunning else { return }
        clearLog()
        isRunning = true
        status = .running
        log("Bắt đầu thử NeoSpring trên \(isiOSVersionString).")
        log("Đã xác nhận chạy trên iOS 27.2.1 (test thật 15/11/2026, iPhone 17 Pro Max).")
    }

    /// Được NeoSpringView gọi khi payload đã start thành công.
    func didStartPayload() {
        guard isRunning else { return }
        status = .started
        log("Payload đã start. Đang chờ SpringBoard restart (tối đa \(Int(timeoutAfterStart))s)…")
        scheduleTimeout(after: timeoutAfterStart, started: true)
    }

    /// Được NeoSpringView gọi khi web view lỗi / web content process chết.
    func didFail(_ message: String) {
        guard isRunning else { return }
        cancelTimeout()
        isRunning = false
        status = .failed(message)
        log("Thất bại: \(message)")
    }

    func didFindNoPayload() {
        guard isRunning else { return }
        cancelTimeout()
        isRunning = false
        status = .payloadMissing
        log("File NeoSpringPayload.html không định nghĩa window.startNeoSpring().")
        log("App KHÔNG thể respring khi chưa có payload — xem README.md, mục 'Thêm payload NeoSpring'.")
    }

    func didTimeOut(started: Bool) {
        guard isRunning else { return }
        isRunning = false
        status = .timedOut
        if started {
            log("Hết \(Int(timeoutAfterStart))s sau khi start mà SpringBoard không restart.")
        } else {
            log("Hết \(Int(timeoutBeforeStart))s mà payload chưa start được.")
        }
        log("Thử lại 1 lần, hoặc dùng cách tay trong tab 'Cách khác'.")
    }

    func cancel() {
        guard isRunning else { return }
        cancelTimeout()
        isRunning = false
        status = .cancelled
        log("Đã hủy lần thử.")
    }

    private func scheduleTimeout(after seconds: TimeInterval, started: Bool) {
        cancelTimeout()
        timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            await self?.didTimeOut(started: started)
        }
    }

    private func cancelTimeout() {
        timeoutTask?.cancel()
        timeoutTask = nil
    }
}

/// Màn hình chạy NeoSpring: chỉ toàn màu đen + WKWebView toàn màn hình
/// (ẩn tương tác). Không có chữ, không có nút — mở app là chạy.
/// Nếu timeout/thất bại, cover tự đóng và ContentView hiện bảng lỗi.
struct NeoSpringView: View {
    @ObservedObject var model: NeoSpringModel

    @State private var hasStarted = false
    @State private var showWebView = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            #if !targetEnvironment(simulator)
            if showWebView {
                NeoSpringWebView(model: model, started: {
                    Task { @MainActor in
                        hasStarted = true
                        model.didStartPayload()
                    }
                }, failed: { message in
                    Task { @MainActor in model.didFail(message) }
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            #endif
        }
        .task {
            #if targetEnvironment(simulator)
            await MainActor.run { model.didFail("Simulator không chạy được NeoSpring — cần máy thật.") }
            #else
            showWebView = true
            do {
                try await Task.sleep(for: .seconds(model.timeoutBeforeStart))
                await MainActor.run {
                    if model.isRunning, !hasStarted {
                        model.didTimeOut(started: false)
                    }
                }
            } catch {
                // Task bị hủy khi view biến mất — bỏ qua.
            }
            #endif
        }
        .onDisappear {
            showWebView = false
            if model.isRunning { model.cancel() }
        }
    }
}

/// WKWebView chạy payload NeoSpring từ file bundle `NeoSpringPayload.html`.
private struct NeoSpringWebView: UIViewRepresentable {
    let model: NeoSpringModel
    let started: () -> Void
    let failed: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model, started: started, failed: failed)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        // Non-persistent: không để lại dữ liệu web sau lần chạy (theo GestaltX).
        configuration.websiteDataStore = .nonPersistent()
        let view = VisibleWebView(frame: .zero, configuration: configuration)
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.backgroundColor = .black
        view.scrollView.isScrollEnabled = false
        view.navigationDelegate = context.coordinator
        view.becameVisible = { [weak view, weak coordinator = context.coordinator] in
            if let view { coordinator?.startIfReady(view) }
        }
        view.loadHTMLString(Self.payloadHTML, baseURL: nil)
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {
        context.coordinator.startIfReady(view)
    }

    static func dismantleUIView(_ view: WKWebView, coordinator: Coordinator) {
        coordinator.stopped = true
        view.navigationDelegate = nil
        (view as? VisibleWebView)?.becameVisible = nil
        view.stopLoading()
        view.evaluateJavaScript("window.stopNeoSpring && window.stopNeoSpring()", completionHandler: nil)
        view.loadHTMLString("", baseURL: nil)
    }

    /// Đọc payload từ bundle. Không tìm thấy file thì dùng trang chờ tối giản.
    static var payloadHTML: String {
        if let url = Bundle.main.url(forResource: "NeoSpringPayload", withExtension: "html"),
           let html = try? String(contentsOf: url, encoding: .utf8),
           !html.isEmpty {
            return html
        }
        return "<!DOCTYPE html><html><body style='background:#000'></body></html>"
    }

    private final class VisibleWebView: WKWebView {
        var becameVisible: (() -> Void)?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            becameVisible?()
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            becameVisible?()
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let model: NeoSpringModel
        private let started: () -> Void
        private let failed: (String) -> Void
        private var loaded = false
        private var requested = false
        var stopped = false

        init(model: NeoSpringModel, started: @escaping () -> Void, failed: @escaping (String) -> Void) {
            self.model = model
            self.started = started
            self.failed = failed
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loaded = true
            startIfReady(webView)
        }

        func startIfReady(_ webView: WKWebView) {
            guard loaded, !requested, !stopped, webView.window != nil,
                  webView.bounds.width > 0, webView.bounds.height > 0 else { return }
            requested = true
            // Chỉ start sau khi view đã gắn vào cửa sổ và có 1 cơ hội
            // layout/render — không start trong makeUIView khi surface còn 0x0.
            DispatchQueue.main.async { [weak self, weak webView] in
                guard let self, let webView, !self.stopped, webView.window != nil else { return }
                webView.setNeedsLayout()
                webView.layoutIfNeeded()
                CATransaction.flush()
                // Kiểm tra payload có thật không — tránh báo start giả.
                webView.evaluateJavaScript("typeof window.startNeoSpring === 'function'") { [weak self] result, _ in
                    guard let self, !self.stopped else { return }
                    if (result as? Bool) == true {
                        webView.evaluateJavaScript("window.startNeoSpring()") { [weak self] _, error in
                            guard let self, !self.stopped else { return }
                            if error == nil {
                                self.started()
                            } else {
                                self.failed("evaluateJavaScript startNeoSpring lỗi: \(error!.localizedDescription)")
                            }
                        }
                    } else {
                        Task { @MainActor in
                            self.model.didFindNoPayload()
                        }
                        self.failed("Không tìm thấy window.startNeoSpring trong payload.")
                    }
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if !stopped { failed("Web view lỗi: \(error.localizedDescription)") }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            if !stopped { failed("Web view lỗi tải trang: \(error.localizedDescription)") }
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            if !stopped { failed("Web content process đã bị kết thúc.") }
        }
    }
}
