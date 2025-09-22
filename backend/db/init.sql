-- ===============================
-- DATABASE: Delivery System
-- ===============================

CREATE DATABASE IF NOT EXISTS catdiff_delivery;
USE catdiff_delivery;

-- ===============================
-- TABLE: Users
-- ===============================
CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    profile_image_url VARCHAR(255),
    user_type ENUM('sender','receiver') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ===============================
-- TABLE: Addresses
-- ===============================
CREATE TABLE IF NOT EXISTS addresses (
    address_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ===============================
-- TABLE: Riders
-- ===============================
CREATE TABLE IF NOT EXISTS riders (
    rider_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    profile_image_url VARCHAR(255),
    vehicle_image_url VARCHAR(255),
    vehicle_plate VARCHAR(20) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ===============================
-- TABLE: Deliveries
-- ===============================
CREATE TABLE IF NOT EXISTS deliveries (
    delivery_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    pickup_address_id BIGINT NOT NULL,
    delivery_address_id BIGINT NOT NULL,
    status ENUM('waiting','accepted','in_transit','delivered') DEFAULT 'waiting',
    package_details TEXT,
    pickup_image_url VARCHAR(255),
    in_transit_image_url VARCHAR(255),
    delivered_image_url VARCHAR(255),
    rider_id BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (pickup_address_id) REFERENCES addresses(address_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_address_id) REFERENCES addresses(address_id) ON DELETE CASCADE,
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id) ON DELETE SET NULL
);

-- ===============================
-- TABLE: Rider Locations
-- ===============================
CREATE TABLE IF NOT EXISTS rider_locations (
    rider_id BIGINT PRIMARY KEY,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id) ON DELETE CASCADE
);
