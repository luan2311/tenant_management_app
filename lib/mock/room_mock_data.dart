// Dữ liệu mock phòng trọ — Sprint 5 sẽ thay bằng DatabaseHelper.
class RoomData {
  final int id;
  final String roomNumber;
  final String facility;
  final double price;
  final double deposit;
  final int maxTenants;
  final String status; // 'empty' | 'rented' | 'maintenance'
  final List<String> amenities;
  final String description;
  final String? imageUrl; // null → hiển thị gradient fallback

  const RoomData({
    required this.id,
    required this.roomNumber,
    required this.facility,
    required this.price,
    required this.deposit,
    required this.maxTenants,
    required this.status,
    required this.amenities,
    required this.description,
    this.imageUrl,
  });
}

// Mock image URLs (Sprint 5: sẽ lưu trong DB hoặc storage)
const _img1 =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBcYTMqNF-4JFXs_fsecbU1ul6onQqFG2J9TXB-0wFiI3m94BzUNH8nEfzXEiVRL0b9ltXOgydyiwPaC4_U-9fEQc3g0V85uf6e4DB_XTXliQB7ocqLnOPQO60xp3AHrByRvMXXAMNGwhe6zrT1EPVymLQA_7SQLg1Kxc3n_s7FJfU0jWchPzeg1MbE7uhLY1hXpWbo7F2QLWcHqXgm0zoe02nWUlw0md_M158_mF7psJjT7d6m1Na3jO9O8rGXlN69NWkk2NPg6i26';
const _img2 =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBq1SA6OHUA99svSHn6LLm3CCX2ocP_Gr86NOLg4YGffUWEyxiBKqLx7hrxSQkSK_eBaWHYIxqE7EurLIcECHdGz4L3BgJybe469YID51fsbLBEYjEp1QfkOFjmUZ8RTTW94kQWK7EXpE613e0MlzhhmklVxqeQZi3m2RC1b1yZ1XzeCR_lbV2dz7j3zDa9vMHem1f_d58LFgPzON1MIomrr3CUi_ypMdA6I8ZY7w1dcUe1PXw2k4ZN9KzZk2Top723cItgXqcQE7mc';
const _img3 =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCHosu7Z-2G-vHhP8lPGE7Mm--88wElXKzwNMm4oF_fyRUZFmTB2dLArQtelx9lqZBO1Stn4La9vTD2JXsm2lyuoKiao_1cLTEcAS41t7ZUdRCrAvCDJTTzIM1z7SEFqfD_Kp9UWhADu831MZeAX0bQMp8BA63cYN7ifC_jrl3UY4HOc_j51E3Siofcx8IxhaJAaVHXU6uTDz13YzuLsJgJgxvy8dqQKzde041j5WMH9hOv0Y22qWMbbxPc-RMKTNR2wH7xj6qu3XNs';

const kMockRooms = <RoomData>[
  RoomData(
    id: 1,
    roomNumber: '101',
    facility: 'Cơ sở Quận 1',
    price: 3500000,
    deposit: 7000000,
    maxTenants: 2,
    status: 'empty',
    amenities: ['Điều hoà', 'WC riêng', 'Wifi', 'Bãi xe', 'Tủ lạnh'],
    description:
        'Phòng thoáng mát, hướng Đông Nam, view nhìn ra sân vườn. Vị trí trung tâm, gần chợ và các tiện ích công cộng.',
    imageUrl: _img1,
  ),
  RoomData(
    id: 2,
    roomNumber: '102',
    facility: 'Cơ sở Quận 1',
    price: 4000000,
    deposit: 8000000,
    maxTenants: 3,
    status: 'empty',
    amenities: ['Điều hoà', 'WC riêng', 'Wifi', 'Bãi xe', 'Tủ lạnh', 'Ban công'],
    description:
        'Phòng rộng rãi có ban công, đón gió tự nhiên. Phù hợp 2–3 người ở chung, gần trường đại học và bệnh viện.',
    imageUrl: _img3,
  ),
  RoomData(
    id: 3,
    roomNumber: '201',
    facility: 'Cơ sở Quận 3',
    price: 2800000,
    deposit: 5600000,
    maxTenants: 1,
    status: 'rented',
    amenities: ['Điều hoà', 'WC riêng', 'Wifi'],
    description:
        'Phòng mini tiện nghi dành cho 1 người ở. Yên tĩnh, sạch sẽ, phù hợp sinh viên hoặc người đi làm.',
  ),
  RoomData(
    id: 4,
    roomNumber: '203',
    facility: 'Cơ sở Quận 3',
    price: 3200000,
    deposit: 6400000,
    maxTenants: 2,
    status: 'empty',
    amenities: ['Điều hoà', 'WC riêng', 'Wifi', 'Bãi xe'],
    description:
        'Phòng đôi yên tĩnh, cách trường đại học 500m. Hẻm sạch, an ninh tốt, có camera an ninh 24/7.',
    imageUrl: _img2,
  ),
  RoomData(
    id: 5,
    roomNumber: '301',
    facility: 'Cơ sở Bình Thạnh',
    price: 5500000,
    deposit: 11000000,
    maxTenants: 4,
    status: 'empty',
    amenities: [
      'Điều hoà', 'WC riêng', 'Wifi', 'Bãi xe',
      'Tủ lạnh', 'Máy giặt', 'Bếp', 'Ban công',
    ],
    description:
        'Căn hộ mini đầy đủ tiện nghi, diện tích 35m², phù hợp nhóm bạn hoặc cặp đôi. Khu vực an toàn, gần siêu thị và công viên.',
  ),
];
