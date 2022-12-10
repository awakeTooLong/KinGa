import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinga/constants/colors.dart';
import 'package:kinga/constants/strings.dart';
import 'package:kinga/domain/student_service.dart';
import 'package:kinga/util/date_utils.dart';

class CreateBasicInfo extends StatefulWidget {
  CreateBasicInfo(this.student, this._profileImage, this.optionalFields, this.formKeyTab, this._onImagePicked, {Key? key}) : super(key: key);

  final Set<String> optionalFields;
  final GlobalKey formKeyTab;
  final Function(Uint8List newProfileImage) _onImagePicked;

  Map<String, dynamic> student;
  Uint8List _profileImage;

  @override
  State<CreateBasicInfo> createState() => _CreateBasicInfoState();
}

class _CreateBasicInfoState extends State<CreateBasicInfo> {
  StudentService studentService = GetIt.I<StudentService>();
  late Set<String> groups;
  late String? selectedGroup;
  String currentName = '';

  @override
  void initState() {
    super.initState();
    groups = studentService.groups;
    selectedGroup = widget.student['group'];
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController birthdayController = TextEditingController();
    birthdayController.text = widget.student['birthday'] != null ? IsoDateUtils.getGermanDateFromIsoDate(widget.student['birthday']) : '';

    return ListView(children: [
      Wrap(children: [
        Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
                color: ColorSchemes.absentColor,
                width: 3
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.all(10),
          child: Form(
            key: widget.formKeyTab,
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(context: context, builder: (context) {
                        return SimpleDialog(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                Container(
                                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                                    child: const Text(Strings.pickImageOption, style: TextStyle(fontSize: 16))
                                ),
                                IntrinsicHeight(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SimpleDialogOption(child: Column(
                                        children: const [
                                          Icon(Icons.camera_alt),
                                          Text(Strings.camera),
                                        ],
                                      ), onPressed: () {
                                        pickImage(context, true).then((success) {if (success) {Navigator.pop(context);}});
                                      },),
                                      const VerticalDivider(),
                                      SimpleDialogOption(child: Column(
                                        children: const [
                                          Icon(Icons.image),
                                          Text(Strings.gallery),
                                        ],
                                      ), onPressed: () {
                                        pickImage(context, false).then((success) {if (success) {Navigator.pop(context);}});
                                      },),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      },);
                    },
                    child: Container(
                        margin: const EdgeInsets.all(15),
                        height: 150,
                        width: 150,
                        child: () {
                          if (widget._profileImage.isEmpty) {
                            return Stack(children: const [
                              Center(
                                  child: Icon(
                                    color: Colors.grey,
                                    Icons.circle,
                                    size: 150,
                                  )),
                              Center(
                                  child: Icon(
                                    color: Colors.white,
                                    Icons.add_a_photo,
                                    size: 80,
                                  )),
                            ]);
                          } else {
                            return Container(
                                height: 150,
                                width: 150,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.antiAlias,
                                //child: Image.file(File(_imagePath))
                                child: Image.memory(widget._profileImage)
                            );
                          }
                        }()),
                  ),
                ),
                IntrinsicWidth(
                  child: DropdownButtonFormField<String>(
                      value: selectedGroup,
                      hint: const Text(Strings.selectGroup),
                      items: [
                        for (var group in groups)
                          DropdownMenuItem(
                              value: group, child: Text(group)),
                        DropdownMenuItem(
                          value: Strings.newGroup,
                          child: Text(Strings.newGroup, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                        )
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          selectedGroup = value!;
                          widget.student['group'] = value;

                          if (value == Strings.newGroup) {
                            showDialog(context: context, builder: (context) {
                              TextEditingController groupNameController = TextEditingController();

                              return AlertDialog(
                                title: const Text(Strings.newGroupInfo),
                                actions: [
                                  TextButton(onPressed: () {
                                    Navigator.of(context).pop();
                                  }, child: const Text(Strings.cancel)),
                                  TextButton(onPressed: () {
                                    Navigator.of(context).pop(groupNameController.text);
                                  }, child: const Text(Strings.confirm))
                                ],
                                content: TextField(
                                  controller: groupNameController,
                                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: Strings.groupName),
                                ),
                            );},
                            ).then((result) {
                              if (result != null) {
                                setState(() {
                                  widget.student['group'] = result;
                                  groups.add(result);
                                  selectedGroup = result;
                                });
                              }
                            });
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return '${Strings.group} ${Strings.requiredFieldMessage}';
                        } else {
                          return null;
                        }
                      }),
                ),
                buildTextField(Strings.firstname, 'firstname'),
                buildTextField(Strings.middlename, 'middlename'),
                buildTextField(Strings.lastname, 'lastname'),
                InkWell(
                    child: buildTextField(Strings.birthday, 'birthday', true,
                            () => showDatePicker(context: context, initialDate: DateTime(DateTime.now().year - 3, 1, 1), firstDate: DateTime(DateTime.now().year - 10, 1, 1), lastDate: DateTime.now()).then((value) {
                          if (value != null) {
                            birthdayController.text = IsoDateUtils.getGermanDateFromDateTime(value);
                            widget.student['birthday'] = IsoDateUtils.getIsoDateFromIsoDateTime(value.toIso8601String());
                          }
                        }), birthdayController)
                ),
                buildTextField(Strings.address, 'address'),
              ],
            ),
          ),
        ),
      ]),
    ]);
  }

  Widget buildTextField(String label, String? property, [bool? readOnly, Function()? onTap, TextEditingController? controller]) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        initialValue: controller == null ? widget.student[property] ?? '' : null,
        textInputAction: TextInputAction.next,
        onChanged: (String? value) {
          if (property != null) widget.student[property] = value?.trim();
        },
        scrollPadding: const EdgeInsets.all(40),
        decoration:
        InputDecoration(border: const OutlineInputBorder(), labelText: label),
        validator: (value) {
          if ((value == null || value.trim().isEmpty) && !widget.optionalFields.contains(property)) {
            return '$label ${Strings.requiredFieldMessage}';
          } else {
            return null;
          }
        },
        controller: controller,
        onTap: onTap,
        readOnly: readOnly ?? false,
      ),
    );
  }

  Future<bool> pickImage(BuildContext context, bool camera) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery);
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          cropStyle: CropStyle.circle,
          uiSettings: [
            AndroidUiSettings(
              lockAspectRatio: true,
              initAspectRatio: CropAspectRatioPreset.square,
              hideBottomControls: true,
              //statusBarColor: Theme.of(context).primaryColor,
              toolbarColor: Theme
                  .of(context)
                  .primaryColor,
              backgroundColor: Theme
                  .of(context)
                  .backgroundColor,
            ),
            IOSUiSettings(
              aspectRatioLockEnabled: true,
              aspectRatioPickerButtonHidden: true,
              rectWidth: 1,
              rectHeight: 1,
            )
          ]);
      if (croppedFile != null) {
        croppedFile.readAsBytes().then((value) => widget._onImagePicked(value) );
        return Future(() => true);
      }
    }
    return Future(() => false);
  }
}