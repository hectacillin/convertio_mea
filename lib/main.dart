import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(UnitConverterApp());
}

class UnitConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      theme: ThemeData(
        primaryColor: Color(0xFF2196F3),
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UnitConverterHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UnitConverterHome extends StatefulWidget {
  @override
  _UnitConverterHomeState createState() => _UnitConverterHomeState();
}

class _UnitConverterHomeState extends State<UnitConverterHome> {
  String selectedCategory = 'Length';
  String fromUnit = 'Meter';
  String toUnit = 'Kilometer';
  TextEditingController inputController = TextEditingController();
  double outputValue = 0.0;
  List<String> favoriteConversions = [];
  List<Map<String, dynamic>> conversionHistory = [];

  final Map<String, Map<String, dynamic>> categories = {
    'Length': {
      'icon': Icons.straighten,
      'color': Color(0xFF2196F3),
      'units': {
        'Meter': 1.0,
        'Kilometer': 0.001,
        'Centimeter': 100.0,
        'Millimeter': 1000.0,
        'Inch': 39.3701,
        'Foot': 3.28084,
        'Yard': 1.09361,
        'Mile': 0.000621371,
      }
    },
    'Weight': {
      'icon': Icons.fitness_center,
      'color': Color(0xFF4CAF50),
      'units': {
        'Kilogram': 1.0,
        'Gram': 1000.0,
        'Pound': 2.20462,
        'Ounce': 35.274,
        'Ton': 0.001,
        'Stone': 0.157473,
      }
    },
    'Temperature': {
      'icon': Icons.thermostat,
      'color': Color(0xFFFF9800),
      'units': {
        'Celsius': 1.0,
        'Fahrenheit': 1.0,
        'Kelvin': 1.0,
        'Rankine': 1.0,
      }
    },
    'Volume': {
      'icon': Icons.local_drink,
      'color': Color(0xFF9C27B0),
      'units': {
        'Liter': 1.0,
        'Milliliter': 1000.0,
        'Gallon': 0.264172,
        'Quart': 1.05669,
        'Pint': 2.11338,
        'Cup': 4.22675,
      }
    },
    'Area': {
      'icon': Icons.crop_square,
      'color': Color(0xFFE91E63),
      'units': {
        'Square Meter': 1.0,
        'Square Kilometer': 0.000001,
        'Square Centimeter': 10000.0,
        'Square Foot': 10.7639,
        'Square Inch': 1550.0,
        'Acre': 0.000247105,
      }
    },
  };

  @override
  void initState() {
    super.initState();
    inputController.addListener(_convertUnits);
    _updateUnitsForCategory();
  }

  void _updateUnitsForCategory() {
    final units = categories[selectedCategory]!['units'] as Map<String, double>;
    fromUnit = units.keys.first;
    toUnit = units.keys.toList()[1];
  }

  void _convertUnits() {
    if (inputController.text.isEmpty) {
      setState(() {
        outputValue = 0.0;
      });
      return;
    }

    double input = double.tryParse(inputController.text) ?? 0.0;
    
    if (selectedCategory == 'Temperature') {
      outputValue = _convertTemperature(input, fromUnit, toUnit);
    } else {
      final units = categories[selectedCategory]!['units'] as Map<String, double>;
      double fromRate = units[fromUnit]!;
      double toRate = units[toUnit]!;
      outputValue = input * toRate / fromRate;
    }
    
    setState(() {});
  }

  double _convertTemperature(double value, String from, String to) {
    double celsius = value;
    
    // Convert to Celsius first
    switch (from) {
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      case 'Rankine':
        celsius = (value - 491.67) * 5 / 9;
        break;
    }

    // Convert from Celsius to target
    switch (to) {
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
      case 'Rankine':
        return (celsius + 273.15) * 9 / 5;
      default:
        return celsius;
    }
  }

  void _addToHistory() {
    if (inputController.text.isNotEmpty && outputValue != 0) {
      setState(() {
        conversionHistory.insert(0, {
          'category': selectedCategory,
          'from': fromUnit,
          'to': toUnit,
          'input': double.parse(inputController.text),
          'output': outputValue,
          'timestamp': DateTime.now(),
        });
        if (conversionHistory.length > 10) {
          conversionHistory.removeLast();
        }
      });
    }
  }

  void _swapUnits() {
    setState(() {
      String temp = fromUnit;
      fromUnit = toUnit;
      toUnit = temp;
      _convertUnits();
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40 : 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit Converter',
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        Text(
                          'Convert units instantly',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.calculate,
                        color: Color(0xFF2196F3),
                        size: isTablet ? 32 : 28,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 30),
                
                // Category Selection
                Container(
                  height: isTablet ? 120 : 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      String category = categories.keys.toList()[index];
                      bool isSelected = category == selectedCategory;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                            _updateUnitsForCategory();
                            _convertUnits();
                          });
                          HapticFeedback.selectionClick();
                        },
                        child: Container(
                          width: isTablet ? 120 : 100,
                          margin: EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: isSelected ? categories[category]!['color'] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                categories[category]!['icon'],
                                color: isSelected ? Colors.white : categories[category]!['color'],
                                size: isTablet ? 32 : 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Conversion Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 32 : 24),
                    child: Column(
                      children: [
                        // From Unit
                        _buildUnitInput(
                          'From',
                          inputController,
                          fromUnit,
                          categories[selectedCategory]!['units'] as Map<String, double>,
                          true,
                          isTablet,
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Swap Button
                        GestureDetector(
                          onTap: _swapUnits,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.swap_vert_rounded,
                              color: Color(0xFF2196F3),
                              size: isTablet ? 32 : 28,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        
                        // To Unit
                        _buildUnitInput(
                          'To',
                          null,
                          toUnit,
                          categories[selectedCategory]!['units'] as Map<String, double>,
                          false,
                          isTablet,
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  inputController.clear();
                                  setState(() {
                                    outputValue = 0.0;
                                  });
                                  HapticFeedback.lightImpact();
                                },
                                icon: Icon(Icons.clear_rounded),
                                label: Text('Clear'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  foregroundColor: Colors.grey[700],
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _addToHistory,
                                icon: Icon(Icons.history_rounded),
                                label: Text('Save'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 30),
                
                // History Section
                if (conversionHistory.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Recent Conversions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: conversionHistory.length,
                      itemBuilder: (context, index) {
                        final history = conversionHistory[index];
                        return Container(
                          width: isTablet ? 200 : 160,
                          margin: EdgeInsets.only(right: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                history['category'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${history['input']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    history['from'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${history['output'].toStringAsFixed(5)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF2196F3),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    history['to'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF2196F3),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitInput(
    String label,
    TextEditingController? controller,
    String selectedUnit,
    Map<String, double> units,
    bool isInput,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: isInput
                    ? TextField(
                        controller: controller,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          outputValue.toStringAsFixed(6),
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    items: units.keys.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (isInput) {
                          fromUnit = newValue!;
                        } else {
                          toUnit = newValue!;
                        }
                        _convertUnits();
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}