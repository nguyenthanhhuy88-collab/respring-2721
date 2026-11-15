// SPDX-License-Identifier: GPL-3.0-only
// ContentView.swift — Respring v1.0: KHÔNG có giao diện, KHÔNG có nút.
//
// Mở app là tự respring luôn, không nút, không chữ, không màn hình chờ,
// không bảng lỗi. Màn hình chỉ toàn màu đen trong lúc chạy. Nếu lần chạy
// đó không respring được thì app cũng không hiện gì thêm — vuốt thoát app
// rồi mở lại là thử lại lần nữa.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: NeoSpringModel
    @State private var showNeoSpring = false
    @State private var autoStarted = false

    var body: some View {
        Color.black.ignoresSafeArea()
            .fullScreenCover(isPresented: $showNeoSpring) {
                NeoSpringView(model: model)
            }
            .onChange(of: model.isRunning) { _, running in
                if !running { showNeoSpring = false }
            }
            .onAppear {
                // Mở app là chạy luôn, chỉ 1 lần mỗi lần mở app.
                // Delay 0.3s để view gắn xong rồi mới present cover.
                guard !autoStarted else { return }
                autoStarted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard !model.isRunning else { return }
                    model.start()
                    showNeoSpring = true
                }
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(NeoSpringModel())
}
