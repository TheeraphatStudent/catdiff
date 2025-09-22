-- ===============================
-- DATABASE: Delivery System (PostgreSQL)
-- ===============================

-- Create custom types
CREATE TYPE user_type AS ENUM ('sender', 'receiver');
CREATE TYPE delivery_status AS ENUM ('waiting', 'accepted', 'in_transit', 'delivered');

-- ===============================
-- TABLE: Users
-- ===============================
CREATE TABLE IF NOT EXISTS users (
    user_id BIGSERIAL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    profile_image_url VARCHAR(255),
    user_type user_type NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for users table
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===============================
-- TABLE: Addresses
-- ===============================
CREATE TABLE IF NOT EXISTS addresses (
    address_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Trigger for addresses table
CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON addresses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===============================
-- TABLE: Riders
-- ===============================
CREATE TABLE IF NOT EXISTS riders (
    rider_id BIGSERIAL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    profile_image_url VARCHAR(255),
    vehicle_image_url VARCHAR(255),
    vehicle_plate VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for riders table
CREATE TRIGGER update_riders_updated_at BEFORE UPDATE ON riders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===============================
-- TABLE: Deliveries
-- ===============================
CREATE TABLE IF NOT EXISTS deliveries (
    delivery_id BIGSERIAL PRIMARY KEY,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    pickup_address_id BIGINT NOT NULL,
    delivery_address_id BIGINT NOT NULL,
    status delivery_status DEFAULT 'waiting',
    package_details TEXT,
    pickup_image_url VARCHAR(255),
    in_transit_image_url VARCHAR(255),
    delivered_image_url VARCHAR(255),
    rider_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (pickup_address_id) REFERENCES addresses(address_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_address_id) REFERENCES addresses(address_id) ON DELETE CASCADE,
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id) ON DELETE SET NULL
);

-- Trigger for deliveries table
CREATE TRIGGER update_deliveries_updated_at BEFORE UPDATE ON deliveries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===============================
-- TABLE: Rider Locations
-- ===============================
CREATE TABLE IF NOT EXISTS rider_locations (
    rider_id BIGINT PRIMARY KEY,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id) ON DELETE CASCADE
);

-- Trigger for rider_locations table
CREATE TRIGGER update_rider_locations_updated_at BEFORE UPDATE ON rider_locations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===============================
-- SEED DATA
-- ===============================

-- Insert sample users
INSERT INTO users (phone_number, password_hash, name, profile_image_url, user_type) VALUES
('0812345678', '$2b$10$dummy.hash.for.demo.purposes.only', 'John Sender', 'https://example.com/john.jpg', 'sender'),
('0812345679', '$2b$10$dummy.hash.for.demo.purposes.only', 'Jane Receiver', 'https://example.com/jane.jpg', 'receiver'),
('0812345680', '$2b$10$dummy.hash.for.demo.purposes.only', 'Bob Receiver', 'https://example.com/bob.jpg', 'receiver');

-- Insert sample addresses
INSERT INTO addresses (user_id, address_line, latitude, longitude) VALUES
(1, '123 Main St, Bangkok', 13.7563, 100.5018),
(2, '456 Oak Ave, Bangkok', 13.7564, 100.5019),
(3, '789 Pine Rd, Bangkok', 13.7565, 100.5020),
(1, '321 Elm St, Bangkok', 13.7566, 100.5021);

-- Insert sample riders
INSERT INTO riders (phone_number, password_hash, name, profile_image_url, vehicle_image_url, vehicle_plate) VALUES
('0912345678', '$2b$10$dummy.hash.for.demo.purposes.only', 'Mike Rider', 'https://example.com/mike.jpg', 'https://example.com/moto.jpg', 'ABC-123'),
('0912345679', '$2b$10$dummy.hash.for.demo.purposes.only', 'Sarah Rider', 'https://example.com/sarah.jpg', 'https://example.com/car.jpg', 'XYZ-456');

-- Insert sample rider locations
INSERT INTO rider_locations (rider_id, latitude, longitude) VALUES
(1, 13.7567, 100.5022),
(2, 13.7568, 100.5023);

-- Insert sample deliveries
INSERT INTO deliveries (sender_id, receiver_id, pickup_address_id, delivery_address_id, package_details, status) VALUES
(1, 2, 1, 2, 'Electronics package', 'waiting'),
(1, 3, 1, 3, 'Clothing package', 'accepted'),
(1, 2, 4, 2, 'Books package', 'in_transit');

-- Update delivery with rider assignment
UPDATE deliveries SET rider_id = 1 WHERE delivery_id = 2;
UPDATE deliveries SET rider_id = 2 WHERE delivery_id = 3;
