class CustomFields {
  String? lastName;
  String? firstName;
  String? skype;
  String? facebook;
  String? twitter;
  String? residence;
  String? hometown;

  CustomFields({
    this.lastName,
    this.firstName,
    this.skype,
    this.facebook,
    this.twitter,
    this.residence,
    this.hometown,
  });

  factory CustomFields.fromJson(Map<String, dynamic> json) => CustomFields(
        lastName: json['lastName'] as String?,
        firstName: json['firstName'] as String?,
        skype: json['skype'] as String?,
        facebook: json['facebook'] as String?,
        twitter: json['twitter'] as String?,
        residence: json['residence'] as String?,
        hometown: json['hometown'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'lastName': lastName,
        'firstName': firstName,
        'skype': skype,
        'facebook': facebook,
        'twitter': twitter,
        'residence': residence,
        'hometown': hometown,
      };
}
