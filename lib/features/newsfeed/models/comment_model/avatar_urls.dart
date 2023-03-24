class AvatarUrls {
  dynamic o;
  dynamic h;
  dynamic l;
  dynamic m;
  dynamic s;

  AvatarUrls({this.o, this.h, this.l, this.m, this.s});

  factory AvatarUrls.fromJson(Map<String, dynamic> json) => AvatarUrls(
        o: json['o'] as dynamic,
        h: json['h'] as dynamic,
        l: json['l'] as dynamic,
        m: json['m'] as dynamic,
        s: json['s'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
        'o': o,
        'h': h,
        'l': l,
        'm': m,
        's': s,
      };
}
