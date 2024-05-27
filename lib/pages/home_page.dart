import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';
import 'movie_page.dart';

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
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data == 'admin') {
          return AdminHomePage();
        } else {
          return RegularHomePage();
        }
      },
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
      ),
      body: Center(
        child: Text('Admin Home'),
      ),
    );
  }
}

class RegularHomePage extends StatefulWidget {
  const RegularHomePage({super.key});

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
      appBar: AppBar(
        title: Text('Movies'),
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
