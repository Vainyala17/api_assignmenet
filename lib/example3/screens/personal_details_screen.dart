import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../widgets/custom_menu.dart';
import 'fetch_data_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? editPersonData;
  final String role;

  const PersonalDetailsScreen({Key? key, this.editPersonData, required this.role}) : super(key: key);

  @override
  _PersonalDetailsScreenState createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subject1Controller = TextEditingController();
  final TextEditingController _subject2Controller = TextEditingController();
  final TextEditingController _subject3Controller = TextEditingController();
  final TextEditingController _pgSubjectController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Form variables
  String _selectedGender = '';
  String _selectedMaritalStatus = '';
  String _selectedState = '';
  String _educationalQualification = '';
  File? _selectedImage;
  String? _existingPhotoPath;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isEditMode = false;
  late String role;
  int? _personId; // To store person ID for edit mode

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      final text = _nameController.text;
      if (text.isNotEmpty && text[0] != text[0].toUpperCase()) {
        final newText = text[0].toUpperCase() + text.substring(1);
        _nameController.value = _nameController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    });
    role = widget.role;
    _loadPersonDataForEdit();
  }

  void _loadPersonDataForEdit() {
    if (widget.editPersonData != null) {
      _isEditMode = true;
      final person = widget.editPersonData!;

      _personId = person['id'];
      _nameController.text = person['name'] ?? '';
      _mobileController.text = person['mobile'] ?? '';
      _emailController.text = person['email'] ?? '';
      _selectedGender = person['gender'] ?? '';
      _selectedMaritalStatus = person['marital_status'] ?? '';
      _selectedState = person['state'] ?? '';
      _educationalQualification = person['educational_qualification'] ?? '';
      _existingPhotoPath = person['photo_path'];
      _addressController.text = person['address'] ?? '';

      if (person['educational_qualification'] == 'Graduate') {
        _subject1Controller.text = person['subject1'] ?? '';
        _subject2Controller.text = person['subject2'] ?? '';
        _subject3Controller.text = person['subject3'] ?? '';
      } else if (person['educational_qualification'] == 'Post Graduate') {
        _pgSubjectController.text = person['pg_subject'] ?? '';
      }
    }
  }

  void _refreshPage() {
    setState(() {
      if (!_isEditMode) {
        _clearForm();
      } else {
        _loadPersonDataForEdit();
      }
    });
    _showSnackBar('Page refreshed successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Details' : 'Personal Details'),
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoSection(),
                SizedBox(height: 24),
                _buildNameField(),
                SizedBox(height: 16),
                _buildMobileField(),
                SizedBox(height: 16),
                _buildEmailField(),
                SizedBox(height: 16),
                _buildAddressField(),
                SizedBox(height: 16),
                _buildGenderField(),
                SizedBox(height: 16),
                _buildMaritalStatusField(),
                SizedBox(height: 16),
                _buildStateField(),
                SizedBox(height: 16),
                _buildEducationalQualificationField(),
                if (_educationalQualification == 'Graduate') ...[
                  SizedBox(height: 16),
                  _buildSubjectFields(),
                ],
                if (_educationalQualification == 'Post Graduate') ...[
                  SizedBox(height: 16),
                  _buildPGSubjectField(),
                ],
                SizedBox(height: 30),
                _buildActionButtons(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: 'Mobile Number *',
        hintText: 'Enter 10-digit mobile number',
        prefixIcon: Icon(Icons.phone),
        helperText: 'Must start with 6, 7, 8, or 9',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Mobile number is required';
        }
        if (value.length != 10) {
          return 'Mobile number must be 10 digits';
        }
        if (!['9', '8', '7', '6'].contains(value[0])) {
          return 'Mobile number must start with 6, 7, 8, or 9';
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      inputFormatters: [
        LengthLimitingTextInputFormatter(25),
      ],
      decoration: InputDecoration(
        labelText: 'Full Name *',
        hintText: 'Enter your full name',
        prefixIcon: Icon(Icons.person),
        helperText: 'Max 25 characters, can include Roman numerals',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        }
        if (value.length > 25) {
          return 'Name cannot exceed 25 characters';
        }
        if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) {
          return 'Name must start with an alphabet';
        }
        if (!RegExp(r'^[a-zA-Z\s\.\-IVXLCDM]+$').hasMatch(value)) {
          return 'Name can only contain letters, spaces, dots, hyphens, and Roman numerals';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      inputFormatters: [
        LengthLimitingTextInputFormatter(100),
      ],
      decoration: InputDecoration(
        labelText: 'Full Address *',
        hintText: 'Enter your full address',
        prefixIcon: Icon(Icons.home),
        helperText: 'Max 100 characters',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Address is required';
        }
        if (value.length > 100) {
          return 'Address cannot exceed 100 characters';
        }
        return null;
      },
    );
  }

  Widget _buildGenderField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Column(
            children: [
              RadioListTile<String>(
                title: Text('Male'),
                value: 'Male',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: Text('Female'),
                value: 'Female',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaritalStatusField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marital Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Column(
            children: [
              RadioListTile<String>(
                title: Text('Single'),
                value: 'Single',
                groupValue: _selectedMaritalStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedMaritalStatus = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: Text('Married'),
                value: 'Married',
                groupValue: _selectedMaritalStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedMaritalStatus = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateField() {
    return DropdownButtonFormField<String>(
      value: _selectedState.isEmpty ? null : _selectedState,
      decoration: InputDecoration(
        labelText: 'State *',
        prefixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: [
        'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
        'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
        'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
        'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
        'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
        'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi'
      ].map((state) => DropdownMenuItem<String>(
        value: state,
        child: Text(state),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedState = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'State is required';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address *',
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email),
        helperText: 'Email should contain @ and domain',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildEducationalQualificationField() {
    return DropdownButtonFormField<String>(
      value: _educationalQualification.isEmpty ? null : _educationalQualification,
      decoration: InputDecoration(
        labelText: 'Educational Qualification *',
        prefixIcon: Icon(Icons.school),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: ['Graduate', 'Post Graduate'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _educationalQualification = value!;
          _subject1Controller.clear();
          _subject2Controller.clear();
          _subject3Controller.clear();
          _pgSubjectController.clear();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Educational qualification is required';
        }
        return null;
      },
    );
  }

  Widget _buildSubjectFields() {
    return Column(
      children: [
        TextFormField(
          controller: _subject1Controller,
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
          decoration: InputDecoration(
            labelText: 'Subject 1 *',
            prefixIcon: Icon(Icons.book),
            helperText: 'Max 15 characters',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (_educationalQualification == 'Graduate' && (value == null || value.isEmpty)) {
              return 'Subject 1 is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _subject2Controller,
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
          decoration: InputDecoration(
            labelText: 'Subject 2 *',
            prefixIcon: Icon(Icons.book),
            helperText: 'Max 15 characters',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (_educationalQualification == 'Graduate' && (value == null || value.isEmpty)) {
              return 'Subject 2 is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _subject3Controller,
          inputFormatters: [LengthLimitingTextInputFormatter(15)],
          decoration: InputDecoration(
            labelText: 'Subject 3 *',
            prefixIcon: Icon(Icons.book),
            helperText: 'Max 15 characters',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (_educationalQualification == 'Graduate' && (value == null || value.isEmpty)) {
              return 'Subject 3 is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPGSubjectField() {
    return TextFormField(
      controller: _pgSubjectController,
      inputFormatters: [LengthLimitingTextInputFormatter(15)],
      decoration: InputDecoration(
        labelText: 'Subject *',
        prefixIcon: Icon(Icons.book),
        helperText: 'Max 15 characters',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (_educationalQualification == 'Post Graduate' && (value == null || value.isEmpty)) {
          return 'Subject is required';
        }
        return null;
      },
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(75),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            )
                : _existingPhotoPath != null && File(_existingPhotoPath!).existsSync()
                ? ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: Image.file(
                File(_existingPhotoPath!),
                fit: BoxFit.cover,
              ),
            )
                : Icon(
              Icons.person,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Only PNG, JPEG files up to 100KB allowed',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearForm,
            child: Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey[400]!),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(_isEditMode ? 'Update' : 'Submit'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final int fileSize = await imageFile.length();

        if (fileSize > 100 * 1024) { // 100 KB
          _showSnackBar('Image size should be less than 100 KB', isError: true);
          return;
        }

        // Check file extension
        String extension = image.path.split('.').last.toLowerCase();
        if (!['png', 'jpg', 'jpeg'].contains(extension)) {
          _showSnackBar('Only PNG and JPEG files are allowed', isError: true);
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  void _clearForm() {
    if (_isEditMode) {
      Navigator.pop(context);
      return;
    }
    _formKey.currentState?.reset();
    setState(() {
      _mobileController.clear();
      _nameController.clear();
      _emailController.clear();
      _subject1Controller.clear();
      _subject2Controller.clear();
      _subject3Controller.clear();
      _pgSubjectController.clear();
      _selectedGender = '';
      _selectedMaritalStatus = '';
      _selectedState = '';
      _educationalQualification = '';
      _selectedImage = null;
      _addressController.clear();
    });
  }

  Future<String?> _saveImageToAppDirectory(File imageFile) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileName = '${_mobileController.text.trim()}_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      final String appDocPath = '${appDocDir.path}/images';

      // Create images directory if it doesn't exist
      await Directory(appDocPath).create(recursive: true);

      final String savedImagePath = '$appDocPath/$fileName';
      final File savedImage = await imageFile.copy(savedImagePath);

      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  // Convert image to base64 string for API
  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  // Check if mobile number already exists via API
  Future<bool> _checkMobileExists(String mobile) async {
    try {
      final response = await ApiService.fetchAllPersons();

      if (response['success']) {
        final List<dynamic> persons = response['data'] ?? [];

        for (var person in persons) {
          // Skip current person in edit mode
          if (_isEditMode && person['id'] == _personId) {
            continue;
          }

          if (person['mobile'] == mobile) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking mobile exists: $e');
      return false;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender.isEmpty) {
      _showSnackBar('Please select gender', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check network connectivity first
      final bool isConnected = await ApiService.checkConnectivity();
      if (!isConnected) {
        _showSnackBar('No internet connection. Please check your network.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check if mobile number already exists
      final bool mobileExists = await _checkMobileExists(_mobileController.text.trim());
      if (mobileExists) {
        _showSnackBar('Mobile number already exists!', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? photo_path;
      String? photoBase64;

      // Handle image
      if (_selectedImage != null) {
        photo_path = await _saveImageToAppDirectory(_selectedImage!);
        photoBase64 = await _convertImageToBase64(_selectedImage!);

        if (photo_path == null || photoBase64 == null) {
          _showSnackBar('Failed to process image', isError: true);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else if (_isEditMode && _existingPhotoPath != null) {
        photo_path = _existingPhotoPath;
        // For existing images, you might want to convert to base64 if needed
        if (File(_existingPhotoPath!).existsSync()) {
          photoBase64 = await _convertImageToBase64(File(_existingPhotoPath!));
        }
      }

      // Prepare data for API
      final Map<String, dynamic> personData = {
        'name': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _selectedGender,
        'marital_status': _selectedMaritalStatus.isNotEmpty ? _selectedMaritalStatus : '',
        'state': _selectedState,
        'educational_qualification': _educationalQualification,
        'address': _addressController.text.trim(),
        'photo_path': photo_path,
        'photoBase64': photoBase64, // Include base64 if your API supports it
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add subjects based on educational qualification
      if (_educationalQualification == 'Graduate') {
        personData['subject1'] = _subject1Controller.text.trim();
        personData['subject2'] = _subject2Controller.text.trim();
        personData['subject3'] = _subject3Controller.text.trim();
      } else if (_educationalQualification == 'Post Graduate') {
        personData['pg_subject'] = _pgSubjectController.text.trim();
      }

      // Add ID for edit mode
      if (_isEditMode && _personId != null) {
        personData['id'] = _personId;
      }

      // Call API
      Map<String, dynamic> response;
      if (_isEditMode) {
        // For edit mode, you might need to add an update API method to ApiService
        // For now, we'll use insert method as a placeholder
        response = await ApiService.insertPersonData(personData);
      } else {
        response = await ApiService.insertPersonData(personData);
      }

      // if (response['success']) {
      //   _showSnackBar(_isEditMode ? 'Data updated successfully!' : 'Data saved successfully!');
      //
      //   // Navigate to fetch data screen
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => FetchDataScreen(role: role),
      //     ),
      //   );
      // }
      if (response['success']) {
        _showSnackBar(_isEditMode ? 'Data updated successfully!' : 'Data saved successfully!');

        // Return to previous screen and trigger refresh
        Navigator.pop(context, true); // 👈 this is the key change
      }

      else {
        _showSnackBar(response['message'] ?? 'Failed to save data', isError: true);
      }

    } catch (e) {
      print('Form submission error: $e');
      _showSnackBar('Error saving data: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subject1Controller.dispose();
    _subject2Controller.dispose();
    _subject3Controller.dispose();
    _pgSubjectController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}