import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/location_point.dart';
import '../services/static_locations.dart';

/// Shows a fixed list of locations to pick from — no Places/Maps API.
/// Pops with the selected [LocationPoint].
class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final title = ModalRoute.of(context)?.settings.arguments as String? ?? 'Select location';
    final filtered = staticLocations
        .where((loc) =>
            loc.name.toLowerCase().contains(_query.toLowerCase()) ||
            loc.address.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
        title: Text(title, style: const TextStyle(color: AppColors.dark)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      autofocus: false,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Filter locations',
                        hintStyle: TextStyle(color: AppColors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No matching locations', style: TextStyle(color: AppColors.grey)))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final loc = filtered[i];
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                          title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(loc.address, style: const TextStyle(color: AppColors.grey)),
                          onTap: () => Navigator.pop(context, loc),
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
