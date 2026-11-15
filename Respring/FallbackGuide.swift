// SPDX-License-Identifier: GPL-3.0-only
// FallbackGuide.swift — Hướng dẫn respring bằng tay khi NeoSpring không chạy.

import SwiftUI

struct FallbackGuideView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Cách respring bằng tay")
                        .font(.title2).bold()

                    Group {
                        Text("1. Display Zoom (chắc ăn nhất, không cần app nào)")
                            .font(.headline)
                        Text("Mở Cài đặt → Màn hình & Độ sáng → Thu phóng màn hình (Display Zoom) → đổi qua lại giữa Tiêu chuẩn và Chữ lớn hơn → bấm Áp dụng / Sử dụng. SpringBoard sẽ tự restart để áp dụng tỉ lệ mới.")
                        Text("App không tự bấm giúp được — iOS không có URL scheme mở thẳng tới trang Display Zoom, và app bên thứ ba không được phép đổi cài đặt hệ thống.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Group {
                        Text("2. Kéo widget (iOS 27.0 / 27.0.1 — trên 27.2.1 chưa xác nhận)")
                            .font(.headline)
                        Text("• Nhấn giữ nền màn hình chính tới khi icon rung (jiggle).\n• Nhấn giữ widget Đồng hồ (Clock) cỡ lớn.\n• Kéo nhanh, lặp đi lặp lại qua lại giữa các trang màn hình chính, TRONG KHI giữ nút Sườn (Side button), dưới 20 giây.\n• Nếu thành công: màn hình đen vài giây rồi quay về Màn hình khóa (respring).")
                        Text("Biến thể iOS 26: giữ widget rồi chạm vào dấu chấm trang dưới cùng thay vì giữ nút Sườn.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Group {
                        Text("Cảnh báo")
                            .font(.headline)
                            .foregroundStyle(.red)
                        Text("• Cách kéo widget là một lỗi giao diện của SpringBoard, không ổn định: có máy respring, có máy đơ cứng, có máy không có tác dụng gì. Trên 27.2 / 27.2.1 khả năng cao Apple đã sửa.\n• Màn hình sẽ nhấp nháy mạnh khi kéo — người nhạy cảm với ánh sáng nhấp nháy (động kinh cảm quang) KHÔNG nên thử.\n• Nếu đơ máy / mất cảm ứng: force restart — bấm nhả Tăng âm lượng → bấm nhả Giảm âm lượng → giữ nút Sườn tới khi hiện logo Apple, rồi thả ra.")
                    }

                    Group {
                        Text("3. Khởi động lại máy (chắc chắn 100%, nhưng không phải respring)")
                            .font(.headline)
                        Text("Nếu chỉ cần máy chạy lại sạch sẽ: giữ nút Sườn + một nút âm lượng → trượt để tắt nguồn, rồi bật lại. Cách này khởi động lại toàn bộ máy, chậm hơn respring.")
                    }
                }
                .padding()
            }
            .navigationTitle("Cách khác")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FallbackGuideView()
}
