# Catdiff - An Delivery Service System


## 🔹 Roles

### Sender
- Create delivery orders.  
- Manage multiple addresses with GPS (Google Maps).  
- Upload photo when goods are waiting for pickup.  
- Track Rider in **real-time on Google Maps**.  
- View multiple Rider locations if many deliveries are active.  

### Receiver
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


## 🔹 Real-Time Flow
1. Sender creates order → system broadcasts `order_created`.  
2. Rider accepts → `rider_assigned` → Sender & Receiver notified.  
3. Rider streams GPS → **Sender & Receiver track Rider live on map**.  
4. Rider updates status (pickup/delivery with photos) → broadcast to all clients.  
5. Order complete → `order_completed`.  