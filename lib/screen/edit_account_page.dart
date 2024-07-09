import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:qlmoney/widgets/edit_item.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({Key? key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  String gender = "man";
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? _imageFile;
  Uint8List? _webImage;
  String? _imageUrl;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('users').child('account');

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void fetchDataFromFirebase() {
    _userRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        var userData = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          nameController.text = userData['name'] ?? '';
          ageController.text = userData['age']?.toString() ?? '';
          emailController.text = userData['email'] ?? '';
          gender = userData['gender'] ?? 'man';
          _imageUrl = userData['avatar'];
        });
      } else {
        print('Dữ liệu từ Firebase không tồn tại hoặc không đúng định dạng.');
      }
    }).catchError((error) {
      print('Đã xảy ra lỗi khi lấy dữ liệu từ Firebase: $error');
    });
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    XFile? pickedFile;
    if (kIsWeb) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List webImage = await pickedFile.readAsBytes();
        setState(() {
          _webImage = webImage;
          _imageFile = null;
        });
      }
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile?.path ?? '');
          _webImage = null;
        });
      }
    }
  }

  // uploadFile
  void uploadFile(File file) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('avatars/${DateTime.now()}.png');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('URL ảnh: $downloadUrl');
    } catch (e) {
      print('Đã xảy ra lỗi khi tải ảnh lên Firebase: $e');
    }
  }

  Future<void> _SaveData() async {
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        email.isEmpty ||
        (_imageFile == null && _webImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin và chọn ảnh.'),
        ),
      );
      return;
    }

    try {
      String imageUrl = '';
      if (kIsWeb && _webImage != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('avatars/${DateTime.now()}.png');
        UploadTask uploadTask = ref.putData(_webImage!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } else if (_imageFile != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('avatars/${DateTime.now()}.png');
        UploadTask uploadTask = ref.putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      setState(() {
        _imageUrl = imageUrl;
      });

      Map<String, dynamic> userData = {
        'name': name,
        'age': int.tryParse(age),
        'email': email,
        'gender': gender,
        'avatar': imageUrl,
      };

      await _userRef.set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dữ liệu và ảnh đã được lưu vào Firebase.'),
        ),
      );
    } catch (error) {
      print('Đã xảy ra lỗi khi tải ảnh lên Firebase: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi khi tải ảnh lên Firebase.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: _SaveData,
              style: IconButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                fixedSize: const Size(55, 50),
                elevation: 3,
              ),
              icon: const Icon(Ionicons.checkmark),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profile",
              style: TextStyle(
                color: Colors.blue.shade300,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _getImage,
              child: Column(
                children: [
                  if (_imageFile != null)
                    Image.file(
                      _imageFile!,
                      height: 100,
                      width: 100,
                    )
                  else if (_webImage != null)
                    Image.memory(
                      _webImage!,
                      height: 100,
                      width: 100,
                    )
                  else if (_imageUrl != null)
                    Image.network(
                      _imageUrl!,
                      height: 100,
                      width: 100,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          'assets/image/avatar.png',
                          height: 100,
                          width: 100,
                        );
                      },
                    )
                  else
                    Image.asset(
                      "assets/image/avatar.png",
                      height: 100,
                      width: 100,
                    ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _getImage,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.lightBlueAccent,
                    ),
                    child: const Text("Upload Image"),
                  ),
                ],
              ),
            ),
            EditItem(
              widget: TextField(
                controller: nameController,
              ),
              title: "Name",
            ),
            const SizedBox(height: 40),
            EditItem(
              title: "Gender",
              widget: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        gender = "man";
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor:
                          gender == "man" ? Colors.green : Colors.grey.shade200,
                      fixedSize: const Size(50, 50),
                    ),
                    icon: Icon(
                      Ionicons.male,
                      color: gender == "man" ? Colors.white : Colors.black,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        gender = "woman";
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: gender == "woman"
                          ? Colors.green
                          : Colors.grey.shade200,
                      fixedSize: const Size(50, 50),
                    ),
                    icon: Icon(
                      Ionicons.female,
                      color: gender == "woman" ? Colors.white : Colors.black,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            EditItem(
              title: "Age",
              widget: TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 40),
            EditItem(
              title: "Email",
              widget: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
