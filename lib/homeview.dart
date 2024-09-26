import 'package:assignment_quad/detailscree.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class ShowList extends StatefulWidget {
  @override
  _ShowListState createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  late Future<List<dynamic>> featuredShows;
  late Future<List<dynamic>> allShows;

  @override
  void initState() {
    super.initState();
    
    featuredShows = fetchShows("top");
    allShows = fetchShows("friends");
  }

  Future<List<dynamic>> fetchShows(String query) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/search/shows?q=all'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load shows');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Netflix'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
             
              showSearch(context: context, delegate: ShowSearchDelegate());
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<dynamic>>(
              future: featuredShows,
              builder:(context,snapshot){
              if (snapshot.hasData) {
            
                  var show = snapshot.data![0]['show'];
                  return _buildPoster(show);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
      
            const Padding(
              padding:  EdgeInsets.all(8.0),
              child: Text(
                'Featured Shows',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: featuredShows,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildFeaturedCarousel(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
           
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Popular Shows',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: allShows,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildShowGrid(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(dynamic show) {
    return show['image'] != null
        ? Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(show['image']['original']),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              alignment: Alignment.bottomLeft,
              padding:const  EdgeInsets.all(16),
              decoration:const  BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Text(
                show['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : Container(); 
  }

  Widget _buildFeaturedCarousel(List<dynamic> shows) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: shows.length,
        itemBuilder: (context, index) {
          var show = shows[index]['show'];
          return GestureDetector(
            onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowDetailsScreen(show: show),
              ),
            );
          }, 
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 120,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      show['image'] != null ? show['image']['medium'] : '',
                      fit: BoxFit.cover,
                      height: 160,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    show['name'],
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildShowGrid(List<dynamic> shows) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: shows.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2 / 3,
      ),
      itemBuilder: (context, index) {
        var show = shows[index]['show'];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowDetailsScreen(show: show),
              ),
            );
          },
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  show['image'] != null ? show['image']['medium'] : '',
                  fit: BoxFit.cover,
                  height: 150,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                show['name'],
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShowSearchDelegate extends SearchDelegate {
  Future<List<dynamic>> fetchSearchResults(String query) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/search/shows?q=$query'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchSearchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found'));
        }

        var results = snapshot.data!;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var show = results[index]['show'];
            return ListTile(
              leading: show['image'] != null
                  ? Image.network(show['image']['medium'], fit: BoxFit.cover)
                  : Icon(Icons.tv),
              title: Text(show['name']),
              subtitle: Text(show['genres'].join(', ')),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text('Search for TV Shows'),
    );
  }
}