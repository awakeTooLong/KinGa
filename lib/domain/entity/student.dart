import 'package:kinga/domain/entity/caregiver.dart';

import 'attendance.dart';
import 'person.dart';

class Student extends Person {

  String studentId;
  String middlename;
  String birthday; // ISO-String
  String address = "";
  String city = "";
  String group = "";
  //List<Incident> incidents = new ArrayList<>();
  //List<Kudo> kudos = new ArrayList<>();
  List<Caregiver> caregivers;
  //List<Person> pickups = new ArrayList<>();
  List<Attendance> attendances = List.empty(growable: true);
  //String profileImage;
  //List<SickNote> sickNotes = new ArrayList<>();
  List<String> allergies;
  List<String> diseases;
  List<String> medicines;
  List<String> healthNotes;
  List<String> permissions;



  Student(
      this.studentId,
      super.firstname,
      this.middlename,
      super.lastname,
      this.birthday,
      this.address,
      this.city,
      this.group,
      this.caregivers,
      //this.profileImage,
      this.allergies,
      this.diseases,
      this.medicines,
      this.healthNotes,
      this.permissions,
  );

  // TODO: other attributes

}

