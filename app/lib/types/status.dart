// [1] รอไรเดอร์มารับสินค้า (pending)
// [2] ไรเดอร์รับงาน (กำลังเดินทางมารับสินค้า) (receiving)
// [3] ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง (riding)
// [4] ไรเดอร์นำส่งสินค้าแล้ว (success)

enum StatusType { pending, receiving, riding, success }

// { <Status_fill> }

class Status_fill {}
//
// [{ <Status_fill> }, { <Status_fill> }, { <Status_fill> }, ...]

class StautsConttainer {}
