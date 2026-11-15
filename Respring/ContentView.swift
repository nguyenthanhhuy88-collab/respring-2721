// SPDX-License-Identifier: GPL-3.0-only
// ContentView.swift — Respring 27 v1.2.0: KHÔNG có giao diện.
//
// Mở app là tự respring luôn, không nút, không chữ, không màn hình chờ.
// Màn hình chỉ toàn màu đen trong lúc chạy. Chỉ khi lần chạy đó thất bại
// (timeout / không có payload / lỗi) thì app mới hiện một bảng lỗi tối
// giản: trạng thái + log + nút THỬ LẠI + đường dẫn "Cách khác".

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: NeoSpringModel
    @State private var showNeoSpring = false
    @State private var showFallback = false
    @State private var autoStarted = false

    /// True khi lần chạy vừa rồi kết thúc mà KHÔNG respring được
    /// (lúc đó mới hiện bảng lỗi; đường chạy bình thường không thấy gì).
    private var showErrorPanel: Bool {
        !model.isRunning && model.status != .idle && model.status != .started
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if showErrorPanel {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        statusCard
                        retryButton
                        logCard
                        fallbackButton
                    }
                    .padding()
                }
            }
        }
        .fullScreenCover(isPresented: $showNeoSpring) {
            NeoSpringView(model: model)
        }
        .onChange(of: model.isRunning) { _, running in
            if !running { showNeoSpring = false }
        }
        .sheet(isPresented: $showFallback) { FallbackGuideView() }
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

    // --- Chỉ dùng khi lần auto chạy thất bại ---

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Không respring được").font(.headline)
                .foregroundStyle(.white)
            Text(model.status.label)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
    }

    private var retryButton: some View {
        Button {
            model.start()
            showNeoSpring = true
        } label: {
            Text("THỬ LẠI")
                .font(.title.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .disabled(model.isRunning)
    }

    private var logCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Nhật ký").font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Xóa log") { model.clearLog() }
                    .font(.callout)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if model.logLines.isEmpty {
                        Text("Chưa có log.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.logLines, id: \.self) { line in
                            Text(line).font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 120, maxHeight: 220)
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
    }

    private var fallbackButton: some View {
        Button("Cách khác nếu không respring được") {
            showFallback = true
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(NeoSpringModel())
}
