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
  String? profilePictureUrl;
  String _selectedBanner = '';
  final List<String> _bannerList = [];
  final _confirmDeleteController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
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
    if (_profileImage != null) {
      profileImageUrl = await _uploadImage(
        _profileImage!,
        'profiles/${widget.user.uid}/profile.jpg',
      );
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
      'username': _usernameController.text.trim(),
      if (profileImageUrl != null) 'profilePicture': profileImageUrl,
      'bannerPicture': _selectedBanner,
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

  Future<void> _reauthenticateAndDeleteAccount(String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: widget.user.email!,
        password: password,
      );

      await widget.user.reauthenticateWithCredential(credential);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .delete();
      await widget.user.delete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la cuenta: ${e.message}')),
      );
    }
  }

  Future<void> _loadBanners() async {
    final ListResult result =
        await FirebaseStorage.instance.ref('banners').listAll();
    final List<String> urls = await Future.wait(
        result.items.map((Reference ref) => ref.getDownloadURL()).toList());

    setState(() {
      _bannerList.addAll(urls);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBanners();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
    setState(() {
      profilePictureUrl = doc['profilePicture'];
      _usernameController.text = doc['username'];
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación de cuenta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Escribe "confirmar" si deseas continuar con la eliminación de tu cuenta'),
              TextFormField(
                controller: _confirmDeleteController,
                decoration: InputDecoration(hintText: 'confirmar'),
              ),
              const SizedBox(height: 20),
              Text(
                  'Por favor, introduce tu contraseña para confirmar la eliminación de la cuenta'),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Contraseña'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_confirmDeleteController.text == 'confirmar') {
                  _reauthenticateAndDeleteAccount(_passwordController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  child: ClipOval(
                    child: profilePictureUrl != null &&
                            profilePictureUrl!.isNotEmpty
                        ? Image.network(
                            profilePictureUrl!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/default_assets/default_pfp.jpg",
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Icon(Icons.edit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            DropdownButtonFormField<String>(
              value: _selectedBanner.isEmpty ? null : _selectedBanner,
              items: _bannerList.map((String url) {
                return DropdownMenuItem<String>(
                  value: url,
                  child: Image.network(
                    url,
                    height: 200,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBanner = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Seleccionar Banner',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Actualizar Perfil'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showDeleteDialog,
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text('Eliminar Cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
