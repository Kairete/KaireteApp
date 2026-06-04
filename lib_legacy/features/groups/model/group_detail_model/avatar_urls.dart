class AvatarUrls {
  String? o;
  String? h;
  String? l;
  String? m;
  String? s;

  AvatarUrls({this.o, this.h, this.l, this.m, this.s});

  factory AvatarUrls.fromJson(Map<String, dynamic> json) => AvatarUrls(
        o: json['o'] as String?,
        h: json['h'] as String?,
        l: json['l'] as String?,
        m: json['m'] as String?,
        s: json['s'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'o': o,
        'h': h,
        'l': l,
        'm': m,
        's': s,
      };
}
