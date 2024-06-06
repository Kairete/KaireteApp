class ProfileBannerUrls {
  String? l;
  String? m;

  ProfileBannerUrls({this.l, this.m});

  factory ProfileBannerUrls.fromJson(Map<String, dynamic> json) {
    return ProfileBannerUrls(
      l: json['l'] as String?,
      m: json['m'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'l': l,
        'm': m,
      };
}
