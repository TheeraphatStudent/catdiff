# Catdiff - An Delivery Service System

## 🔹 Roles

### User - Sender

- Create delivery orders.
- Manage multiple addresses with GPS (Google Maps).
- Upload photo when goods are waiting for pickup.
- Track Rider in **real-time on Google Maps**.
- View multiple Rider locations if many deliveries are active.

### User - Receiver

- View incoming deliveries.
- Track Rider location in **real-time** on map.
- See multiple Rider deliveries at once.

### Rider

- Accept one delivery job at a time.
- Share live GPS location via WebSocket.
- Upload proof photos for pickup and delivery.
- Use in-app **Google Maps navigation**.
- Must be within **20m** of pickup/drop-off to confirm status.

## 🔹 Delivery Status Flow

1. **[1] Waiting Pickup** – Sender uploads product photo.
2. **[2] Rider Accepted & En Route** – Rider traveling to Sender.
3. **[3] Picked Up** – Rider uploads pickup photo, delivering.
4. **[4] Delivered** – Rider uploads delivery photo, order complete.

## 🔹 Tech Stack

### Backend

- **NestJS** (REST API + WebSocket Gateway)
- **SQL Database** (Cloud SQL: Postgres/MySQL)
- **Cloud Storage (GCS)** for photos
- **Redis (Cloud Memorystore)** for WebSocket scaling
- **Deployed on Cloud Run (Docker containers)**

### Frontend (Flutter)

- Role-based app (Sender / Receiver / Rider)
- **Packages**:
  - `http` → REST API calls
  - `socket_io_client` → WebSocket events
  - `google_maps_flutter` → Rider tracking on map
  - `geolocator` → Rider GPS
  - `image_picker` → photo uploads

## 🔹 Google Cloud Integration

- **Maps SDK (Flutter)** → interactive map & live tracking
- **Geocoding API** → address → GPS conversion
- **Distance Matrix API** → ETA between Rider & destination
- **Directions API** → Rider navigation routes
- **Cloud Monitoring & Logging** → production observability

## API Security Setup

- **Package Name**: `com.example.app`
- **API Key**: Restricted to Android apps only
- **Quick SHA-1 Tool**: Run `python3 get_sha1.py` to get your SHA-1 fingerprint

## 🔹 Real-Time Flow

1. Sender creates order → system broadcasts `order_created`.
2. Rider accepts → `rider_assigned` → Sender & Receiver notified.
3. Rider streams GPS → **Sender & Receiver track Rider live on map**.
4. Rider updates status (pickup/delivery with photos) → broadcast to all clients.
5. Order complete → `order_completed`.

# Requirement Gathering

## ประเภทผู้ใช้

ระบบแบ่งผู้ใช้เป็น 2 ประเภท:

1. **ผู้ใช้ระบบ (User)**
2. **ไรเดอร์ (Rider)**

---

## ข้อมูลขั้นต่ำที่ต้องมี

### ผู้ใช้ (User)

- หมายเลขโทรศัพท์
- รหัสผ่าน
- ชื่อ
- รูปภาพของผู้ใช้
- ที่อยู่
- พิกัด GPS ของสถานที่รับสินค้า
  - สามารถเลือกพิกัดโดย **จิ้มจากแผนที่** หรือ **กรอกที่อยู่แล้วระบบแสดงตำแหน่งอัตโนมัติ**
  - ผู้ใช้สามารถมี **มากกว่า 1 ที่อยู่**

### ไรเดอร์ (Rider)

- หมายเลขโทรศัพท์
- รหัสผ่าน
- ชื่อ
- รูปภาพของไรเดอร์
- รูปยานพาหนะ
- ทะเบียนรถ

---

## สถานะของสินค้าที่จัดส่ง

1. รอไรเดอร์มารับสินค้า
2. ไรเดอร์รับงาน (กำลังเดินทางมารับสินค้า)
3. ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง
4. ไรเดอร์นำส่งสินค้าแล้ว

---

## ผู้ใช้ระบบ - ผู้ส่งสินค้า (Sender)

- สามารถสร้างและดูรายการส่งสินค้า พร้อมรายละเอียดของสินค้า
- ค้นหาผู้รับได้จาก **หมายเลขโทรศัพท์**
- เลือกที่อยู่และพิกัดของผู้รับจากหมายเลขโทรศัพท์
- สามารถส่งสินค้า **มากกว่า 1 รายการ**
- ถ่ายรูปประกอบสถานะ **[1] รอไรเดอร์มารับสินค้า** ได้ 1 รูป
- ดูข้อมูลไรเดอร์และตำแหน่งบนแผนที่แบบ **Real-time** เมื่อสินค้าอยู่ในสถานะ:
  - [2] ไรเดอร์รับงาน
  - [3] ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง
- หากมีสินค้า **มากกว่า 1 ชิ้น** สามารถดูพิกัดตำแหน่งของไรเดอร์บนแผนที่ **แบบรวม**

---

## ผู้ใช้ระบบ - ผู้รับสินค้า (Receiver)

- ดูรายการและสถานะสินค้าที่กำลังถูกส่งมา
- สามารถมีสินค้ากำลังจัดส่ง **มากกว่า 1 รายการ**
- ดูข้อมูลไรเดอร์และตำแหน่งบนแผนที่แบบ **Real-time** เมื่อสินค้าอยู่ในสถานะ:
  - [1] รอไรเดอร์มารับสินค้า
  - [2] ไรเดอร์รับงาน
  - [3] ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง
- หากมีสินค้า **มากกว่า 1 ชิ้น** สามารถดูพิกัดตำแหน่งของไรเดอร์บนแผนที่ **แบบรวม**

---

## ไรเดอร์ (Rider)

- ดูงานและรับงานส่งสินค้าได้ **ครั้งละ 1 สินค้าเท่านั้น**
- ไรเดอร์ 2 คน จะ **รับงานเดียวกันไม่ได้**
- ไรเดอร์ 1 คน จะ **รับงาน 2 งานไม่ได้**
- งานใหม่จะแสดงผลแบบ **Real-time**
- ถ่ายรูปประกอบสถานะ:
  - [3] ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง
  - [4] ไรเดอร์นำส่งสินค้าแล้ว  
    (สถานะละ 1 รูป)
- หลังจากกดรับงาน แอปจะแสดงหน้า **ตำแหน่งไรเดอร์บนแผนที่แบบ Real-time** เท่านั้น
- เมื่อส่งสินค้าเสร็จ สามารถกลับมารอรับงานใหม่
- ไรเดอร์สามารถรับและส่งสินค้าได้ต่อเมื่อ **อยู่ห่างจากพิกัดรับ/ส่งสินค้าไม่เกิน 20 เมตร**
