import 'package:flutter/material.dart';
import '../models.dart';
import '../api_service.dart';
import 'class_selection_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<School> _searchResults = [];
  bool _isLoading = false;

  void _searchSchool() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final results = await _apiService.searchSchool(query);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });

    if (results.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No results found. Please re-enter the school name.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search School'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter high school name...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchSchool(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchSchool,
                  child: Text('Search'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final school = _searchResults[index];
                        return ListTile(
                          title: Text(school.schoolName),
                          subtitle: Text('Code: ${school.schoolCode}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassSelectionScreen(school: school),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
