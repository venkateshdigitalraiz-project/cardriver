import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../../navigation/presentation/pages/main_navigator_page.dart';

class DocumentUploadPage extends StatefulWidget {
  final CustomerEntity customer;

  const DocumentUploadPage({super.key, required this.customer});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  XFile? _frontImage;
  XFile? _backImage;
  XFile? _panImage;
  bool _isBankAdded = false;

  void _setImage(String type, XFile? file) {
    if (file == null) return;
    setState(() {
      if (type == 'front') {
        _frontImage = file;
      } else if (type == 'Back') {
        _backImage = file;
      } else if (type == 'PAN Card') {
        _panImage = file;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF135029);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // Driving Licence Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Driving Licence*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    _buildAddRow('front', darkGreen, currentFile: _frontImage),
                    const Divider(height: 1, thickness: 1),
                    _buildAddRow('Back', darkGreen, currentFile: _backImage),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // PAN Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildAddRow('PAN Card', darkGreen, currentFile: _panImage, isBoldTitle: true),
              ),
              const SizedBox(height: 16),
              
              // Bank Account
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildAddRow('Add Bank Account*', darkGreen, isBoldTitle: true, isBankRow: true, isBankAdded: _isBankAdded),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Final submission action
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => MainNavigatorPage(customer: widget.customer),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA5BFA3), // Light sage green (disabled look)
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddRow(String title, Color darkGreen, {XFile? currentFile, bool isBoldTitle = false, bool isBankRow = false, bool isBankAdded = false}) {
    bool hasData = isBankRow ? isBankAdded : (currentFile != null);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isBankRow && currentFile != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        File(currentFile.path),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (isBankRow && isBankAdded)
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.account_balance, color: Colors.green, size: 30),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isBoldTitle ? darkGreen : Colors.black87,
                      fontWeight: isBoldTitle ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isBankRow) {
                _showBankAccountSheet(context, darkGreen);
              } else {
                _showPicker(title);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: hasData ? Colors.grey.shade600 : darkGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(hasData ? 'CHANGE' : 'ADD'),
          ),
        ],
      ),
    );
  }

  void _showBankAccountSheet(BuildContext context, Color darkGreen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Bank Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 24),
              _buildBottomSheetTextField('Bank Name', 'e.g. State Bank of India'),
              const SizedBox(height: 16),
              _buildBottomSheetTextField('Account Number', 'e.g. 1234567890'),
              const SizedBox(height: 16),
              _buildBottomSheetTextField('IFSC Code', 'e.g. SBIN0001234'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isBankAdded = true;
                  });
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SAVE BANK DETAILS'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black87),
                title: const Text('Gallery', style: TextStyle(color: Colors.black87)),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                    _setImage(type, pickedFile);
                  } catch (e) {
                    // Handle error
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.black87),
                title: const Text('Camera', style: TextStyle(color: Colors.black87)),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                    _setImage(type, pickedFile);
                  } catch (e) {
                    // Handle error
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
