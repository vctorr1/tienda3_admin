import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:tienda3_admin/db/product.dart';
import '../db/category.dart';
import '../db/brand.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final CategoryService _categoryService = CategoryService();
  final BrandService _brandService = BrandService();
  final ProductService _productService = ProductService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<DocumentSnapshot> brands = [];
  List<DocumentSnapshot> categories = [];
  List<DropdownMenuItem<String>> categoriesDropDown = [];
  List<DropdownMenuItem<String>> brandsDropDown = [];
  String? _currentCategory;
  String? _currentBrand;

  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;

  List<String> selectedSizes = [];
  File? _image1;
  File? _image2;
  File? _image3;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCategories();
    _getBrands();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    return categories.map((category) {
      final categoryValue = category['category']?.toString() ??
          'Unknown'; // Asegúrate de que el valor es String y maneja nulos
      return DropdownMenuItem<String>(
        child: Text(categoryValue),
        value: categoryValue,
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> getBrandsDropdown() {
    return brands.map((brand) {
      final brandValue = brand['brand']?.toString() ??
          'Unknown'; // Convierte a String y maneja valores nulos
      return DropdownMenuItem<String>(
        child: Text(brandValue),
        value: brandValue,
      );
    }).toList();
  }

  void _getCategories() async {
    final List<DocumentSnapshot> data = await _categoryService.getCategories();
    if (data.isNotEmpty) {
      setState(() {
        categories = data;
        categoriesDropDown = getCategoriesDropdown();
        _currentCategory = categories[0]['category'];
      });
    }
  }

  void _getBrands() async {
    final List<DocumentSnapshot> data = await _brandService.getBrands();
    if (data.isNotEmpty) {
      setState(() {
        brands = data;
        brandsDropDown = getBrandsDropdown();
        _currentBrand = brands[0]['brand'];
      });
    }
  }

  bool _isImagePickerActive = false;

  void _selectImage(Future<XFile?> pickImage, int imageNumber) async {
    try {
      if (_isImagePickerActive) return;

      _isImagePickerActive = true;
      final pickedImage = await pickImage;
      _isImagePickerActive = false;

      if (pickedImage != null) {
        final File tempImg = File(pickedImage.path);
        setState(() {
          switch (imageNumber) {
            case 1:
              _image1 = tempImg;
              break;
            case 2:
              _image2 = tempImg;
              break;
            case 3:
              _image3 = tempImg;
              break;
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void changeSelectedCategory(String? selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  void changeSelectedBrand(String? selectedBrand) {
    setState(() => _currentBrand = selectedBrand);
  }

  void changeSelectedSize(String size) {
    setState(() {
      if (selectedSizes.contains(size)) {
        selectedSizes.remove(size);
      } else {
        selectedSizes.add(size);
      }
    });
  }

  Widget _displayChild(File? image) {
    if (image == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        image,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild1() {
    return _displayChild(_image1);
  }

  Widget _displayChild2() {
    return _displayChild(_image2);
  }

  Widget _displayChild3() {
    return _displayChild(_image3);
  }

  void validateAndUpload() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      if (_image1 != null && _image2 != null && _image3 != null) {
        if (selectedSizes.isNotEmpty) {
          final FirebaseStorage storage = FirebaseStorage.instance;

          String getImageFileName(int index) {
            return "${index}${DateTime.now().millisecondsSinceEpoch}.jpg";
          }

          UploadTask task1 = storage
              .ref()
              .child("products/${getImageFileName(1)}")
              .putFile(_image1!);

          UploadTask task2 = storage
              .ref()
              .child("products/${getImageFileName(2)}")
              .putFile(_image2!);

          UploadTask task3 = storage
              .ref()
              .child("products/${getImageFileName(3)}")
              .putFile(_image3!);

          final imageUrl1 = await (await task1).ref.getDownloadURL();
          final imageUrl2 = await (await task2).ref.getDownloadURL();
          final imageUrl3 = await (await task3).ref.getDownloadURL();

          final imageList = [imageUrl1, imageUrl2, imageUrl3];

          await _productService.uploadProduct({
            "name": _productNameController.text,
            "price": double.parse(_priceController.text),
            "sizes": selectedSizes,
            "images": imageList,
            "quantity": int.parse(_quantityController.text),
            "brand": _currentBrand,
            "category": _currentCategory,
          });

          _formKey.currentState!.reset();
          setState(() => isLoading = false);

          Navigator.pop(context); // Regresar al menú principal
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Select at least one size")));
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("All images must be provided")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: white,
        leading: IconButton(
          icon: Icon(Icons.close, color: black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Añadir producto",
          style: TextStyle(color: black),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              onPressed: () => _selectImage(
                                ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                ),
                                1,
                              ),
                              child: _displayChild1(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              onPressed: () => _selectImage(
                                ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                ),
                                2,
                              ),
                              child: _displayChild2(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              onPressed: () => _selectImage(
                                ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                ),
                                3,
                              ),
                              child: _displayChild3(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Enter a product name with 10 characters at maximum',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: red, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration:
                            InputDecoration(hintText: 'Nombre del producto'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You must enter the product name';
                          } else if (value.length > 10) {
                            return 'Product name can\'t have more than 10 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Category: ',
                            style: TextStyle(color: red),
                          ),
                        ),
                        DropdownButton<String>(
                          items: categoriesDropDown,
                          onChanged: changeSelectedCategory,
                          value: _currentCategory,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Brand: ',
                            style: TextStyle(color: red),
                          ),
                        ),
                        DropdownButton<String>(
                          items: brandsDropDown,
                          onChanged: changeSelectedBrand,
                          value: _currentBrand,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Quantity'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You must enter the product quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Price'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You must enter the product price';
                          }
                          return null;
                        },
                      ),
                    ),
                    Text('Available Sizes'),
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal, // Permitir desplazamiento horizontal
                      child: Row(
                        children: <Widget>[
                          for (var size in ['XS', 'S', 'M', 'L', 'XL', 'XXL'])
                            Row(
                              children: <Widget>[
                                Checkbox(
                                  value: selectedSizes.contains(size),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedSizes.add(size);
                                      } else {
                                        selectedSizes.remove(size);
                                      }
                                    });
                                  },
                                ),
                                Text(size),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (var size in [
                            '28',
                            '30',
                            '32',
                            '34',
                            '36',
                            '38',
                            '40',
                            '42',
                            '44',
                            '46',
                            '48',
                            '50'
                          ])
                            Row(
                              children: <Widget>[
                                Checkbox(
                                  value: selectedSizes.contains(size),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedSizes.add(size);
                                      } else {
                                        selectedSizes.remove(size);
                                      }
                                    });
                                  },
                                ),
                                Text(size),
                              ],
                            ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      child: Text('Add Product'),
                      onPressed: validateAndUpload,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
