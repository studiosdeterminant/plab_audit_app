import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import '../../cubits/stores/stores_cubit.dart';
import '../../helpers/colors.dart';

class AddStoreScreen extends StatefulWidget {
  // final String agentId;

  const AddStoreScreen({Key? key}) : super(key: key);

  @override
  _AddStoreScreenState createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '', address = '', location = '', area = '', pincode = '';
  bool isSubmitting = false;

final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  bool isFetchingLocation = false;

  String? selectedClientId;
  String? selectedCycleId;

  List<Map<String, String>> clients = [];
  List<Map<String, String>> cycles = [];

  @override
  void dispose() {
    addressController.dispose();
    locationController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchClients(); // safe to call now
    });
  }

  Future<void> fetchCycles(String clientId) async {
    final storesCubit = BlocProvider.of<StoresCubit>(context);
    final data = await storesCubit.getCycles(clientId);
    setState(() {
      cycles = data.map<Map<String, String>>((item) => {
        "cycleId": item["cycleId"],
        "cycleTitle": item["cycleTitle"]
      }).toList();
    });
  }

  Future<void> fetchClients() async {
    final data = await BlocProvider.of<StoresCubit>(context).getClients();
    setState(() {
      clients = data.map<Map<String, String>>((item) => {
        "clientId": item["clientId"],
        "clientTitle": item["clientTitle"]
      }).toList();
    });
  }

  Future<void> _fetchAndFillLocation() async {
    setState(() => isFetchingLocation = true);
    try {
      loc.Location locationService = loc.Location();

      bool serviceEnabled = await locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await locationService.requestService();
        if (!serviceEnabled) {
          setState(() => isFetchingLocation = false);
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await locationService.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await locationService.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() => isFetchingLocation = false);
          return;
        }
      }

      loc.LocationData locData = await locationService.getLocation();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        locData.latitude ?? 0.0,
        locData.longitude ?? 0.0,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          address = "${placemark.street ?? ''}, ${placemark.subLocality ?? ''}, ${placemark.locality ?? ''}".trim();
          area = "${placemark.administrativeArea ?? ''}".trim();
          location = "${placemark.locality ?? ''}".trim();
          pincode = "${placemark.postalCode ?? ''}".trim();

          addressController.text = address;
          areaController.text = area;
          locationController.text = location;
          pincodeController.text = pincode;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch location: $e")),
      );
    }
    setState(() => isFetchingLocation = false);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && selectedClientId != null && selectedCycleId != null) {
      setState(() => isSubmitting = true);

      final payload = {
        "clientId": selectedClientId!,
        "cycleId": selectedCycleId!,
        "stores": [
          {
            "storeTitle": title,
            "storeAddress": address,
            "storeLocation": location,
            "storeArea": area,
            "storePincode": pincode,
          }
        ]
      };

      final response = await sendStoreToBackend(payload);
      if (response) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add store")),
        );
      }

      setState(() => isSubmitting = false);
    }
  }

  Future<bool> sendStoreToBackend(Map<String, dynamic> data) async {
    await Future.delayed(Duration(seconds: 1)); // Optional mock delay
    final result = await BlocProvider.of<StoresCubit>(context).addStore(data);
    return true; // Use actual backend result
  }

  Widget _buildInputCard({required String label, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.white,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }


  Widget _buildDropdown({
    required String label,
    required List<Map<String, String>> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return _buildInputCard(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: _inputDecoration("Select $label"),
        items: items
            .map((item) => DropdownMenuItem<String>(
          value: item["clientId"] ?? item["cycleId"],
          child: Text(item["clientTitle"] ?? item["cycleTitle"] ?? ""),
        ))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Please select $label" : null,
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF0F5),
      appBar: AppBar(
        backgroundColor: cSecondary,
        title: Text("Add Store"),
        foregroundColor: cWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdown(
                label: "Client",
                items: clients,
                value: selectedClientId,
                onChanged: (val) {
                  setState(() {
                    selectedClientId = val;
                    selectedCycleId = null;
                    cycles = [];
                  });
                  fetchCycles(val!);
                },
              ),
              if (selectedClientId != null)
                _buildDropdown(
                  label: "Cycle",
                  items: cycles,
                  value: selectedCycleId,
                  onChanged: (val) => setState(() => selectedCycleId = val),
                ),
              _buildInputCard(
                label: "Store Title",
                child: TextFormField(
                  decoration: _inputDecoration("Enter store title"),
                  onChanged: (val) => title = val,
                  validator: (val) => val!.isEmpty ? "Field required" : null,
                ),
              ),
              Row(
                children: [
                  Expanded(child: Container()),
                  isFetchingLocation
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        )
                      : ElevatedButton.icon(
                          icon: Icon(Icons.my_location),
                          label: Text("Use My Location"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cPrimary,
                            foregroundColor: cWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _fetchAndFillLocation,
                        ),
                ],
              ),
              _buildInputCard(
                label: "Address",
                child: TextFormField(
                  controller: addressController,
                  decoration: _inputDecoration("Enter address"),
                  onChanged: (val) => address = val,
                  validator: (val) => val!.isEmpty ? "Field required" : null,
                ),
              ),
              _buildInputCard(
                label: "Location",
                child: TextFormField(
                  controller: locationController,
                  decoration: _inputDecoration("Enter location"),
                  onChanged: (val) => location = val,
                ),
              ),
              _buildInputCard(
                label: "Area",
                child: TextFormField(
                  controller: areaController,
                  decoration: _inputDecoration("Enter area"),
                  onChanged: (val) => area = val,
                ),
              ),
              _buildInputCard(
                label: "Pincode",
                child: TextFormField(
                  controller: pincodeController,
                  decoration: _inputDecoration("Enter pincode"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => pincode = val,
                ),
              ),
              const SizedBox(height: 20),
              isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cSecondary,
                  foregroundColor: cWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitForm,
                child: Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
