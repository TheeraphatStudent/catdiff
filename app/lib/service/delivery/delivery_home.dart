class DeliveryHome {
  List<Map> getDeliveryMockDataFormFirebase() {
    return [
      {
        "profileImageUrl": "https://cataas.com/cat",
        "name": "Alice Johnson",
        "status": "pending",
        "delivery_id": "DEL12345",
        "pickup_address_id": "ADDR1001",
        "delivery_address_id": "ADDR2001",
        "pickup_pkg_images_url": [
          "https://example.com/packages/pkg1_img1.png",
          "https://example.com/packages/pkg1_img2.png",
        ],
        "created_at": "2025-09-29T10:15:00Z",
        "updated_at": "2025-09-29T11:00:00Z",
        "delivered_at": null,
        "pickup_at": null,
        "sended_pkg_detail": "Small box, fragile",
        "sended_pkg_img_url": "https://example.com/packages/pkg1_main.png",
      },
      {
        "profileImageUrl": "https://example.com/images/user2.png",
        "name": "Michael Smith",
        "status": "riding",
        "delivery_id": "DEL67890",
        "pickup_address_id": "ADDR1002",
        "delivery_address_id": "ADDR2002",
        "pickup_pkg_images_url": ["https://example.com/packages/pkg2_img1.png"],
        "created_at": "2025-09-28T08:00:00Z",
        "updated_at": "2025-09-28T12:30:00Z",
        "delivered_at": "2025-09-28T12:00:00Z",
        "pickup_at": "2025-09-28T09:00:00Z",
        "sended_pkg_detail": "Medium parcel, electronics",
        "sended_pkg_img_url": "https://example.com/packages/pkg2_main.png",
      },
    ];
  }
}
