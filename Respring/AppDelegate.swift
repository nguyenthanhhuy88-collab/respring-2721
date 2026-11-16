// SPDX-License-Identifier: GPL-3.0-only
// AppDelegate.swift — Respring v1.1: entry point UIKit, KHÔNG SwiftUI.
//
// Bấm icon là respring luôn: không SwiftUI, không scene, không màn hình chờ,
// không nút, không chữ. AppDelegate tạo UIWindow đen + RespringViewController
// làm root; view controller tạo WKWebView và chạy payload ngay khi trang load
// xong VÀ view đã hiện lên màn hình.

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .black
        window.rootViewController = RespringViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
