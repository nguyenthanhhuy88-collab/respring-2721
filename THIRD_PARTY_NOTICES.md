# Third-party notices — Respring 27

## 1. NeoSpring (kỹ thuật + dự án)
- Kỹ thuật WebKit GPU process respring: **@neonmodder123** — https://github.com/neonmodder123
- Swift implementation: **@skadz108** — https://github.com/skadz108
- Dự án NeoSpring: **@rooootdev** — https://github.com/rooootdev/neospring
- NeoSpring không tự khai license riêng trong repo của nó; project này ghi
  credit đầy đủ ở đây, trong code (`Respring/NeoSpring.swift`) và trong app.

## 2. GestaltX — bản thích ứng tham chiếu cho harness NeoSpring
- Repo: https://github.com/huamidev/GestaltX — **GNU GPL v3**.
- Đã dùng làm tham chiếu: cấu trúc `NeoSpringView` (VisibleWebView,
  Coordinator, startIfReady, timeout 10s/20s, hủy, loại Simulator,
  non-persistent WebKit data store) và phần ghi chú sửa lỗi escaping /
  kích thước random-data request.
- Vì project này thích ứng từ code GPL-3.0 nên toàn bộ project Respring 27
  được phát hành dưới **GNU GPL v3** (xem file `LICENSE`).
- GestaltX cũng ghi: "NeoSpring itself is credited as a project/technique
  reference, not assigned a license it does not declare."

## 3. AirCard-iOS — tham khảo thêm (KHÔNG sao chép code)
- Repo: https://github.com/Mak5er/AirCard-iOS — **MIT License**,
  Copyright (c) 2026 Johnny Franks.
- AirCard-iOS có file `ios-app/RespringHelper.swift` (NeoSpring) và ghi
  hỗ trợ iOS 18.0 – 27.2 beta 2. File này KHÔNG được đọc hay sao chép vào
  project này trong quá trình làm (bị chặn đọc trong môi trường làm việc);
  logic NeoSpring ở đây lấy từ GestaltX (mục 2). Thông tin version
  "27.2 beta 2 / beta 3+ bị vá đường airlift" được trích từ README của
  AirCard-iOS.

## 4. RespringApp cũ (34306/mdc0) — KHÔNG dùng
- `respringapp.ipa` v1.0, bundle `com.respring.app`, là binary PosterBoard
  nội bộ của Apple (iOS 16.6 internal SDK), chỉ chạy tới iOS 27.0.
  Project này KHÔNG chứa, KHÔNG vá, KHÔNG dùng lại file đó.

## 5. Logo
- Logo app (nền xanh lá gradient, spinner trắng 8 vạch) là file do user
  Harry cung cấp (`Logo-goc.jpg` trong repo này). Bản quyền thuộc về
  người cung cấp; chỉ dùng làm icon cho app này.
