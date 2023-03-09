
class School{
  late final String name;
  late final num acceptedAppliers;
  late final num appliers;
  late String? postDistrict;
  late String? education;

  late String? campusName;
  late double? campusLat;
  late double? campusLon;

  School({required this.name, required this. acceptedAppliers, required this.appliers, this.postDistrict, this.education, this.campusName, this.campusLat, this.campusLon});
}