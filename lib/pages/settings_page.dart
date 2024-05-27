import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  final User user;
  const SettingsPage({Key? key, required this.user}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _usernameController = TextEditingController();
  File? _profileImage;
  File? _bannerImage;

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _bannerImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String> _uploadImage(File image, String path) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask;
    return await storageReference.getDownloadURL();
  }

  Future<void> _updateUserProfile() async {
    String? profileImageUrl;
    String? bannerImageUrl;

    if (_profileImage != null) {
      profileImageUrl = await _uploadImage(
        _profileImage!,
        'profiles/${widget.user.uid}/profile.jpg',
      );
    }

    if (_bannerImage != null) {
      bannerImageUrl = await _uploadImage(
        _bannerImage!,
        'profiles/${widget.user.uid}/banner.jpg',
      );
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
      'username': _usernameController.text.trim(),
      if (profileImageUrl != null) 'profilePicture': profileImageUrl,
      if (bannerImageUrl != null) 'bannerPicture': bannerImageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil actualizado con éxito')),
    );
  }

  Future<void> _deleteAccount() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .delete();
    await widget.user.delete();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
    setState(() {
      _usernameController.text = doc['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _profileImage == null
                ? Text('No se ha seleccionado una foto de perfil.')
                : Image.file(_profileImage!),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery, true),
              child: Text('Seleccionar Foto de Perfil'),
            ),
            const SizedBox(height: 20),
            _bannerImage == null
                ? Text('No se ha seleccionado un banner.')
                : Image.file(_bannerImage!),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery, false),
              child: Text('Seleccionar Banner'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Actualizar Perfil'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteAccount,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: Text('Eliminar Cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
