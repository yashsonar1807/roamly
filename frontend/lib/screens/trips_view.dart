import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/custom_text_field.dart';
import 'share_journey_screen.dart';

class TripsView extends StatefulWidget {
  const TripsView({super.key});

  @override
  State<TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<TripsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.accessToken != null) {
        Provider.of<TripProvider>(
          context,
          listen: false,
        ).fetchTrips(auth.accessToken!);
      }
    });
  }

  void _confirmDelete(BuildContext context, String tripId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              Provider.of<TripProvider>(context, listen: false).deleteTrip(
                token: auth.accessToken!,
                id: tripId,
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip deleted.')),
                  );
                },
                onError: (err) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: Colors.red),
                  );
                }
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (ctx) => _EditTripDialog(trip: trip),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripProvider = Provider.of<TripProvider>(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 860),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Travel Itineraries & Journeys',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flight_takeoff_rounded, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${tripProvider.trips.length} Adventures',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: tripProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tripProvider.errorMessage != null
                ? Center(
                    child: Text(
                      tripProvider.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  )
                : tripProvider.trips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_travel_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No trips logged yet.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the Create tab to write your first travel log!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: tripProvider.trips.length,
                    itemBuilder: (context, index) {
                      final trip = tripProvider.trips[index];
                      
                      String dateRangeStr = 'Dates TBD';
                      if (trip['startDate'] != null && trip['endDate'] != null) {
                         try {
                           final start = DateTime.parse(trip['startDate']);
                           final end = DateTime.parse(trip['endDate']);
                           dateRangeStr = '${dateFormat.format(start)} - ${dateFormat.format(end)}';
                         } catch (_) {}
                      }

                      Color statusColor = Colors.blue;
                      if (trip['status'] == 'Completed') statusColor = Colors.green;
                      if (trip['status'] == 'Cancelled') statusColor = Colors.red;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      trip['title'] ?? '',
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusColor),
                                    ),
                                    child: Text(
                                      trip['status'] ?? 'Upcoming',
                                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.pin_drop_rounded, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(trip['destination'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(dateRangeStr, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  if (trip['budget'] != null && trip['budget'] > 0)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.attach_money_rounded, size: 16, color: Colors.green),
                                        Text('${trip['budget']}'),
                                      ],
                                    ),
                                  if (trip['hotel'] != null && trip['hotel'].toString().isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.hotel_rounded, size: 16, color: Colors.indigo),
                                        Text('${trip['hotel']}'),
                                      ],
                                    ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.orange),
                                      Text('${trip['spotsCount'] ?? 0} spots'),
                                    ],
                                  ),
                                ],
                              ),
                              if (trip['notes'] != null && trip['notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Notes: ${trip['notes']}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (trip['status'] == 'Completed')
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ShareJourneyScreen(trip: trip),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.share_rounded, size: 18, color: Colors.blue),
                                      label: const Text('Share Journey', style: TextStyle(color: Colors.blue)),
                                    ),
                                  TextButton.icon(
                                    onPressed: () => _showEditDialog(context, trip),
                                    icon: const Icon(Icons.edit_rounded, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _confirmDelete(context, trip['_id'], trip['title']),
                                    icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

class _EditTripDialog extends StatefulWidget {
  final Map<String, dynamic> trip;
  const _EditTripDialog({required this.trip});

  @override
  State<_EditTripDialog> createState() => _EditTripDialogState();
}

class _EditTripDialogState extends State<_EditTripDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _destinationController;
  late TextEditingController _budgetController;
  late TextEditingController _hotelController;
  late TextEditingController _notesController;
  
  String _selectedStatus = 'Upcoming';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.trip['title']);
    _destinationController = TextEditingController(text: widget.trip['destination']);
    _budgetController = TextEditingController(text: widget.trip['budget']?.toString() ?? '');
    _hotelController = TextEditingController(text: widget.trip['hotel'] ?? '');
    _notesController = TextEditingController(text: widget.trip['notes'] ?? '');
    
    _selectedStatus = widget.trip['status'] ?? 'Upcoming';
    
    if (widget.trip['startDate'] != null) {
      _startDate = DateTime.tryParse(widget.trip['startDate']);
    }
    if (widget.trip['endDate'] != null) {
      _endDate = DateTime.tryParse(widget.trip['endDate']);
    }
  }

  void _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    tripProvider.updateTrip(
      token: auth.accessToken!,
      id: widget.trip['_id'],
      title: _titleController.text.trim(),
      destination: _destinationController.text.trim(),
      budget: double.tryParse(_budgetController.text.trim()),
      hotel: _hotelController.text.trim(),
      notes: _notesController.text.trim(),
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
      onSuccess: () {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip updated!')));
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
      }
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _hotelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return AlertDialog(
      title: const Text('Edit Trip'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: _titleController,
                  label: 'Title',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _destinationController,
                  label: 'Destination',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _budgetController,
                        label: 'Budget (\$)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['Upcoming', 'Completed', 'Cancelled']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _hotelController,
                  label: 'Hotel',
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickDateRange,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Trip Dates'),
                    child: Text(
                      _startDate != null && _endDate != null
                          ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                          : 'Select Dates',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _notesController,
                  label: 'Notes',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveChanges, child: const Text('Save')),
      ],
    );
  }
}
