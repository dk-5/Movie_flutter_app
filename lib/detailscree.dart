import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowDetailsScreen extends StatefulWidget {
  final int? selectedSeason;
  final dynamic show;
   
  ShowDetailsScreen({required this.show, this.selectedSeason});

  @override
  State<ShowDetailsScreen> createState() => _ShowDetailsScreenState();
}

class _ShowDetailsScreenState extends State<ShowDetailsScreen> {
    List<dynamic> episodes = [];

  List<int> seasons = [];

Future<List<dynamic>> fetchEpisodes(int showId) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/shows/$showId/episodes'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load episodes');
    }
  }

  Future<Map<String,dynamic>> fetchCast(int showId) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/shows/$showId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cast');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.show['name']),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show poster
            widget.show['image'] != null
                ? Image.network(
                    widget.show['image']['original'],
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show name
                  Text(
                    widget.show['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10,),
            
                  // Genres
                  Text(
                    'Genres: ${widget.show['genres'].isNotEmpty ? widget.show['genres'].join(', ') : 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Language: ${widget.show['language'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                
                  const SizedBox(height: 20),
                  // Fetch and display episodes
                  FutureBuilder<List<dynamic>>(
                    future: fetchEpisodes(widget.show['id']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Episodes:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (var episode in snapshot.data!)
                              Card(
                                margin:EdgeInsets.symmetric(vertical: 8.0), // Space between cards
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0), // Padding inside the card
                                  child: Row(
                                    children: [
                                      // Episode image
                                      episode['image'] != null
                                          ? Image.network(
                                              episode['image']['medium'],
                                              width: 80,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 80,
                                              height: 120,
                                              color: Colors.grey, // Placeholder for no image
                                            ),
                                      SizedBox(width: 16), // Space between image and text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              episode['name'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Season ${episode['season']} | Episode ${episode['number']}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              '${episode['runtime']} min',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                  
                                  ]
                                )
            )
          ]
        )
      )
    );
                                                 
  }
}






