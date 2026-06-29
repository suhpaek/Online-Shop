class Profile {
  final String image;
  final String name;
  final String email;
  final String phone;
  final String country;
  final String city;
  final String address;
  final String postalCode;
  
  Profile({
    required this.image,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
    required this.address,
    required this.postalCode,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      image: json['image'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      postalCode: json['postalCode'] as String,
    );
  }
}