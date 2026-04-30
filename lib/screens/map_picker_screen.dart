import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class MapPickerScreen extends StatefulWidget {
  final String initialLocation;
  const MapPickerScreen(
      {super.key, this.initialLocation = 'Galle Road, Colombo'});
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final Completer<GoogleMapController> _ctrl = Completer();
  LatLng? _picked;
  bool _loading = true;
  LatLng _center = const LatLng(6.9271, 79.8612); // Colombo fallback

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  Future<void> _initPosition() async {
    final pos = await LocationService().getCurrentPosition();
    if (pos != null) {
      _center = LatLng(pos.latitude, pos.longitude);
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 15),
              onMapCreated: (c) => _ctrl.complete(c),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: (latLng) => setState(() => _picked = latLng),
              markers: _picked == null
                  ? {}
                  : {
                      Marker(
                          markerId: const MarkerId('picked'),
                          position: _picked!,
                          draggable: true,
                          onDragEnd: (p) => setState(() => _picked = p))
                    },
            ),
          Positioned(top: 12, left: 12, child: _backButton(context)),
          if (_picked != null)
            Positioned(
                top: 12,
                right: 12,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Location selected',
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                          '${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)}',
                          style: GoogleFonts.inter(fontSize: 12)),
                    ]))),
          Positioned(bottom: 20, left: 20, right: 20, child: _submitButton())
        ]),
      ),
    );
  }

  Widget _backButton(BuildContext ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)
              ]),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1C1C1E)),
        ),
      );

  Widget _submitButton() => SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _picked == null
              ? null
              : () async {
                  // Reverse geocode
                  final addr = await LocationService().getAddressFromLatLng(
                      _picked!.latitude, _picked!.longitude);
                  if (!mounted) return;
                  Navigator.pop(context, {
                    'address': addr,
                    'lat': _picked!.latitude,
                    'lng': _picked!.longitude
                  });
                },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Text('Submit',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
      );
}