// SPDX-License-Identifier: GPL-3.0-only
// ContentView.swift — Giao diện chính (tiếng Việt) của Respring 27.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: NeoSpringModel
    @State private var showNeoSpring = false
    @State private var showFallback = false
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statusCard
                    respringButton
                    logCard
                    fallbackButton
                    aboutButton
                }
                .padding()
            }
            .navigationTitle("Respring 27")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAbout = true } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $showFallback) { FallbackGuideView() }
            .sheet(isPresented: $showAbout) { AboutView() }
            .fullScreenCover(isPresented: $showNeoSpring) {
                NeoSpringView(model: model)
            }
            .onChange(of: model.isRunning) { _, running in
                if !running { showNeoSpring = false }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Respring cho iOS 27.2.1")
                .font(.title2).bold()
            Text("iPhone 17 Pro Max • \(model.isiOSVersionString)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Dùng kỹ thuật NeoSpring (WebKit GPU process). Trạng thái trên iOS 27.2.1: CHƯA XÁC NHẬN — đã test tới iOS 27.2 beta 2 theo AirCard-iOS. Nếu không respring được thì dùng cách tay ở dưới.")
                .font(.callout)
                .foregroundStyle(.orange)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trạng thái").font(.headline)
            Text(model.status.label)
            if model.status == .payloadMissing {
                Text("File NeoSpringPayload.html kèm theo app hiện chỉ là placeholder. Muốn respring thật, thêm payload NeoSpring theo README.md rồi build lại.")
                    .font(.callout)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
    }

    private var respringButton: some View {
        Button {
            model.start()
            showNeoSpring = true
        } label: {
            Text("RESPRING")
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
                Spacer()
                Button("Xóa log") { model.clearLog() }
                    .font(.callout)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if model.logLines.isEmpty {
                        Text("Chưa có log. Bấm RESPRING để thử.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.logLines, id: \.self) { line in
                            Text(line).font(.system(.footnote, design: .monospaced))
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

    private var aboutButton: some View {
        Button("Giới thiệu & credit") {
            showAbout = true
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
    }
}

private struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Respring 27 — v1.0.0")
                        .font(.title3).bold()
                    Text("App respring tối giản cho iOS 27.2.1, dùng kỹ thuật NeoSpring qua WebKit GPU process. Không dùng killall / FBSystemService (sandbox chặn), không xin entitlement private, không cần jailbreak.")
                    Text("Credit")
                        .font(.headline)
                    Text("• Kỹ thuật WebKit GPU respring: @neonmodder123\n• Swift implementation: @skadz108\n• Dự án NeoSpring: @rooootdev — github.com/rooootdev/neospring\n• Harness tham chiếu: GestaltX (GPL-3.0) — github.com/huamidev/GestaltX\n• AirCard-iOS (MIT) — github.com/Mak5er/AirCard-iOS")
                    Text("Giấy phép: GNU GPL v3 (xem file LICENSE).")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("Cảnh báo: sao lưu máy trước khi thử. Kỹ thuật này cố tình làm SpringBoard restart; nếu màn hình đơ thì force restart (Tăng âm lượng → Giảm âm lượng → giữ nút Sườn). Tác giả không chịu trách nhiệm nếu máy gặp sự cố.")
                        .font(.callout)
                        .foregroundStyle(.orange)
                }
                .padding()
            }
            .navigationTitle("Giới thiệu")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NeoSpringModel())
}
