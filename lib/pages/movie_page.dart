import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class MoviePage extends StatelessWidget {
  final Movie movie;

  const MoviePage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: movie.getMovieBanner(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Icon(Icons.error));
                } else {
                  return Image.network(snapshot.data as String);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Director: ${movie.director}'),
                  Text('Year: ${movie.year}'),
                  Text('Genre: ${movie.genre}'),
                  SizedBox(height: 8),
                  Text(movie.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
