class CustomFields {
  String? firstName;
  String? lastName;
  String? residence;
  String? hometown;
  String? skype;
  String? facebook;
  String? twitter;

  CustomFields({
    this.firstName,
    this.lastName,
    this.residence,
    this.hometown,
    this.skype,
    this.facebook,
    this.twitter,
  });

  factory CustomFields.fromJson(Map<String, dynamic> json) => CustomFields(
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        residence: json['residence'] as String?,
        hometown: json['hometown'] as String?,
        skype: json['skype'] as String?,
        facebook: json['facebook'] as String?,
        twitter: json['twitter'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'residence': residence,
        'hometown': hometown,
        'skype': skype,
        'facebook': facebook,
        'twitter': twitter,
      };
}
