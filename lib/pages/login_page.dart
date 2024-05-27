import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import './home_page.dart';
import '../widgets/login_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controlador de animación
  Timer? _flickerTimer; // Temporizador para el parpadeo de neon
  double _opacity = 1.0; // Inicia con opacidad al 100%
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _visible = true; // Variable para mostrar u ocultar la contraseña
  Route homePageRoute = MaterialPageRoute(builder: (BuildContext context) {
    return const HomePage();
  });

  // Instancia de la clase LoginWidget que contiene aspectos de diseño del login
  LoginWidget login = LoginWidget();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration:
          const Duration(milliseconds: 500), // Corta duración para los cambios
      vsync: this,
    );
    startFlickeringEffect();
  }

  // efecto de parpadeo de Neon
  void startFlickeringEffect() {
    _flickerTimer?.cancel(); // Cancelar cualquier parpadeo de neon
    _flickerTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      setState(() {
        final random = math.Random();
        _opacity = random.nextBool() ? 1.0 : random.nextDouble();
      });
    });
  }

  @override
  void dispose() {
    disposeControlers();
    _flickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 170),
              Container(
                width: 300,
                height: 80,
                alignment: AlignmentGeometry.lerp(
                    Alignment.centerLeft, Alignment.centerRight, 0.5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: login.getNeonColor().withOpacity(_opacity * 0.9),
                    width: 5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 11, 7, 21),
                  boxShadow: [
                    BoxShadow(
                      color: login.getNeonColor().withOpacity(_opacity * 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: login.getNeonColor().withOpacity(_opacity * 0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: login.getLogo(30),
              ),
              const SizedBox(height: 80),
              const Align(
                alignment: Alignment.centerLeft,
                widthFactor: 6,
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 360,
                height: 35,
                alignment: AlignmentGeometry.lerp(
                    Alignment.centerLeft, Alignment.centerRight, 0.5),
                child: AutoSizeText(
                  login.getMensaje(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                  minFontSize: 10,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    textFormFieldLogin(Icons.person, ' Usuario',
                        'Escribe tu usuario', _usernameController, false),
                    const SizedBox(height: 40),
                    textFormFieldLogin(Icons.lock, ' Contraseña',
                        'Escribe tu contraseña', _passwordController, false),
                    const SizedBox(height: 40),
                    Container(
                      width: 200,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            login.getStartingColor(),
                            login.getNeonColor(),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pushReplacement(context, homePageRoute);
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textFormFieldLogin(IconData icon, String label, String hint,
      TextEditingController controller, bool isUser) {
    if (label == ' Usuario') {
      return TextFormField(
        onTap: () {
          if (_formKey.currentState?.validate() == false) {
            _formKey.currentState?.reset();
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Usuario requerido';
          }
          if (value != 'a') {
            return 'Usuario incorrecto';
          }
          return null;
        },
        autofocus: isUser,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          fillColor: Colors.white.withOpacity(0.05),
          filled: true,
          prefixIcon:
              Icon(icon, color: const Color.fromARGB(255, 232, 57, 115)),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white10,
          ),
          labelText: label,
          alignLabelWithHint: true,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF252525),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF03A9F4),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFB00020),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFB00020),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        controller: controller,
      );
    } else {
      return TextFormField(
        onTap: () {
          if (_formKey.currentState?.validate() == false) {
            _formKey.currentState?.reset();
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Contraseña requerida';
          }
          if (value != 'a') {
            return 'Contraseña incorrecta';
          }
          return null;
        },
        obscureText: _visible,
        autofocus: isUser,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          fillColor: Colors.white.withOpacity(0.05),
          filled: true,
          prefixIcon:
              Icon(icon, color: const Color.fromARGB(255, 232, 57, 115)),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white10,
          ),
          labelText: label,
          alignLabelWithHint: true,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF252525),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFF03A9F4),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFB00020),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFB00020),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          suffixIcon: IconButton(
            icon: Icon(_visible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _visible = !_visible;
              });
            },
          ),
        ),
        controller: controller,
      );
    }
  }

  void disposeControlers() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _formKey.currentState?.dispose();
  }
}
