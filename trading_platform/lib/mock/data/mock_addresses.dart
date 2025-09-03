import '../../models/user/address.dart';

/// 僅輸出 Address 實例，不定義任何 MockAddress 類別
final List<Address> mockAddresses = [
  Address(
    id: 'addr_001',
    userId: 'user_777',
    recipientName: '王小明',
    phoneNumber: '0912-345-678',
    country: '台灣',
    province: '台北市',
    city: '信義區',
    district: '信義區',
    streetAddress1: '松壽路 1 號',
    streetAddress2: '17 樓',
    postalCode: '110',
    isDefault: true,
  ),
  Address(
    id: 'addr_002',
    userId: 'user_777',
    recipientName: '王小明（公司）',
    phoneNumber: '02-1234-5678',
    country: '台灣',
    province: '台北市',
    city: '大安區',
    district: '大安區',
    streetAddress1: '復興南路一段 390 號',
    streetAddress2: '8 樓',
    postalCode: '106',
    isDefault: false,
  ),
];
