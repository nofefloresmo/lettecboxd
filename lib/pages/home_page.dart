import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';
import 'movie_page.dart';
import 'login_page.dart';
import 'add_movie_page.dart'; // Página para agregar nuevas películas
import 'my_reviews_page.dart'; // Página de reseñas del usuario

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  Future<String> getUserRole() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc['role'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == 'admin') {
          return AdminHomePage(user: user);
        } else {
          return RegularHomePage(user: user);
        }
      },
    );
  }
}

class AdminHomePage extends StatefulWidget {
  final User user;
  const AdminHomePage({super.key, required this.user});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    Movie.loadMovies().then((movies) {
      setState(() {
        _movies = movies;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/banners/BTTF.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/banners/DH.jpg"),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.logout,
                        color: Colors.redAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                });
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMoviePage()),
            );
          },
          child: const Text('Agregar Película'),
        ),
      ),
    );
  }
}

class RegularHomePage extends StatefulWidget {
  final User user;
  const RegularHomePage({super.key, required this.user});

  @override
  State<RegularHomePage> createState() => _RegularHomePageState();
}

class _RegularHomePageState extends State<RegularHomePage> {
  List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    Movie.loadMovies().then((movies) {
      setState(() {
        _movies = movies;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/banners/BTTF.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/banners/DH.jpg"),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.home,
                        color: Colors.blueAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.blueAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Inicio',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.blueAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.rate_review,
                        color: Colors.greenAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.greenAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.greenAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Mis reseñas',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.greenAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.greenAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyReviewsPage()));
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.logout,
                        color: Colors.redAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                });
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Películas'),
      ),
      body: _movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                Movie movie = _movies[index];
                return FutureBuilder(
                  future: movie.getMoviePoster(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text(movie.name),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(
                        leading: Icon(Icons.error),
                        title: Text(movie.name),
                      );
                    } else {
                      return ListTile(
                        leading: Image.network(snapshot.data as String),
                        title: Text(movie.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoviePage(movie: movie),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
