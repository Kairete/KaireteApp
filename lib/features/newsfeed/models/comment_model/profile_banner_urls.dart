class ProfileBannerUrls {
  dynamic l;
  dynamic m;

  ProfileBannerUrls({this.l, this.m});

  factory ProfileBannerUrls.fromJson(Map<String, dynamic> json) {
    return ProfileBannerUrls(
      l: json['l'] as dynamic,
      m: json['m'] as dynamic,
    );
  }

  Map<String, dynamic> toJson() => {
        'l': l,
        'm': m,
      };
}
