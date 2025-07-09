import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../widgets/custom_menu.dart';
import 'personal_details_screen.dart';

class FetchDataScreen extends StatefulWidget {
  final String role;

  const FetchDataScreen({Key? key, required this.role}) : super(key: key);

  @override
  _FetchDataScreenState createState() => _FetchDataScreenState();
}

class _FetchDataScreenState extends State<FetchDataScreen> {
  List<Map<String, dynamic>> _personData = [];
  bool _isLoading = true;
  late String role;

  @override
  void initState() {
    super.initState();
    role = widget.role;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);

      final result = await ApiService.fetchAllPersons();

      if (result['success']) {
        setState(() {
          _personData = List<Map<String, dynamic>>.from(result['data']);
          _isLoading = false;
        });
      } else {
        _showSnackBar('Error fetching data: ${result['message']}', isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('Error fetching data: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _refreshPage() {
    _fetchData();
    _showSnackBar('Page refreshed successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fetch Data',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          CustomMenu(
            context: context,
            onRefresh: _refreshPage,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Loading data...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
            : _personData.isEmpty
            ? _buildEmptyState()
            : _buildDataList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonalDetailsScreen(role: role),
            ),
          ).then((result) {
            if (result == true) {
              _fetchData();
            }
          });
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Person',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No Data Found',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add some personal details first',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalDetailsScreen(role: role),
                ),
              ).then((result) {
                if (result == true) {
                  _fetchData();
                }
              });
            },
            icon: Icon(Icons.add),
            label: Text('Add First Person'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _personData.length,
        itemBuilder: (context, index) {
          final person = _personData[index];
          return _buildPersonCard(person, index);
        },
      ),
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> person, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, size: 35, color: Colors.blue[600]),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person['name'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        person['mobile'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (role == 'Supervisor' || role == 'Manager')
                  PopupMenuButton<String>(
                    iconSize: 28,
                    onSelected: (value) {
                      if (value == 'edit') {
                        _navigateToEditScreen(person);
                      } else if (value == 'delete') {
                        _showDeleteDialog(person);
                      }
                    },
                    itemBuilder: (context) {
                      List<PopupMenuEntry<String>> items = [];

                      if (role == 'Supervisor' || role == 'Manager') {
                        items.add(
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 24, color: Colors.blue),
                                SizedBox(width: 12),
                                Text('Edit', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      }

                      if (role == 'Manager') {
                        items.add(
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 24, color: Colors.red),
                                SizedBox(width: 12),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return items;
                    },
                  ),
              ],
            ),
            Divider(thickness: 1.5, height: 24),

            _buildInfoRow(Icons.email, 'Email', person['email'] ?? 'N/A'),
            _buildInfoRow(Icons.home, 'Address', person['address'] ?? 'N/A'),
            _buildInfoRow(Icons.person, 'Gender', person['gender'] ?? 'N/A'),
            _buildInfoRow(
              Icons.favorite,
              'Marital Status',
              person['marital_status'] ?? 'Not Specified',
            ),
            _buildInfoRow(Icons.location_on, 'State', person['state'] ?? 'N/A'),
            _buildInfoRow(
              Icons.school,
              'Education',
              person['educational_qualification'] ?? 'N/A',
            ),

            if (person['educational_qualification'] == 'Graduate' &&
                person['subjects'] != null) ...[
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.book, size: 20, color: Colors.grey[600]),
                  SizedBox(width: 12),
                  Text(
                    'Subjects: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${person['subjects']['subject1'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 15)),
                        Text('${person['subjects']['subject2'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 15)),
                        Text('${person['subjects']['subject3'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            if (person['educational_qualification'] == 'Post Graduate' &&
                person['subject'] != null) ...[
              _buildInfoRow(
                Icons.book,
                'Subject',
                person['pg_subject'] ?? 'N/A',
              ),
            ],

            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                SizedBox(width: 8),
                Text(
                  'Added: ${_formatTimestamp(person['timestamp'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(Map<String, dynamic> person) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PersonalDetailsScreen(
            editPersonData: person,
            role: role,
          ),
        ),
      );

      if (result == true) {
        _fetchData();
      }
    } catch (e) {
      _showSnackBar('Error navigating to edit screen: $e', isError: true);
    }
  }

  void _showDeleteDialog(Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Delete Person',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this person?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person, size: 20),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                person['name'] ?? 'N/A',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              Text(
                                person['mobile'] ?? 'N/A',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email: ${person['email'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePerson(person);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Delete', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePerson(Map<String, dynamic> person) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Deleting person...'),
                ],
              ),
            ),
          ),
        ),
      );

      final result = await ApiService.deletePersonData(person['id']);

      Navigator.of(context).pop(); // Close loading dialog

      if (result['success']) {
        _showSnackBar('Person deleted successfully!');
        _fetchData();
      } else {
        _showSnackBar('Error deleting person: ${result['message']}', isError: true);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showSnackBar('Error deleting person: $e', isError: true);
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime dateTime;
      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Unknown';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}