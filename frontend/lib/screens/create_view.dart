import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/custom_text_field.dart';

class CreateView extends StatefulWidget {
  final VoidCallback onTripCreated;

  const CreateView({super.key, required this.onTripCreated});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _spotsController = TextEditingController();
  final _notesController = TextEditingController();
  final _budgetController = TextEditingController();
  final _hotelController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = 'Upcoming';

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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    tripProvider.createTrip(
      token: auth.accessToken!,
      title: _titleController.text.trim(),
      destination: _destinationController.text.trim(),
      spotsCount: int.tryParse(_spotsController.text.trim()) ?? 0,
      notes: _notesController.text.trim(),
      budget: double.tryParse(_budgetController.text.trim()),
      hotel: _hotelController.text.trim(),
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip added to your itineraries successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _destinationController.clear();
        _spotsController.clear();
        _notesController.clear();
        _budgetController.clear();
        _hotelController.clear();
        setState(() {
          _startDate = null;
          _endDate = null;
          _selectedStatus = 'Upcoming';
        });
        widget.onTripCreated();
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _spotsController.dispose();
    _notesController.dispose();
    _budgetController.dispose();
    _hotelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripProvider = Provider.of<TripProvider>(context);
    
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Plan a New Adventure',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize your next journey with dates, budget, hotel, and packing notes.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),

                CustomTextField(
                  controller: _titleController,
                  label: 'Trip Title',
                  hint: 'e.g. Summer Beach Getaway',
                  prefixIcon: Icons.title_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a trip title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _destinationController,
                  label: 'Destination Name',
                  hint: 'e.g. Goa Beaches, Goa',
                  prefixIcon: Icons.pin_drop_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please specify the destination';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _spotsController,
                        label: 'Visited Places Count',
                        hint: 'e.g. 5',
                        prefixIcon: Icons.location_on_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _budgetController,
                        label: 'Budget (\$)',
                        hint: 'e.g. 1500',
                        prefixIcon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _hotelController,
                  label: 'Hotel / Accommodation',
                  hint: 'e.g. Hilton Resort',
                  prefixIcon: Icons.hotel_rounded,
                ),
                const SizedBox(height: 16),
                
                // Calendar Date Range Picker
                InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Trip Dates',
                      prefixIcon: const Icon(Icons.calendar_month_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _startDate != null && _endDate != null
                          ? '${dateFormat.format(_startDate!)}  -  ${dateFormat.format(_endDate!)}'
                          : 'Select date range',
                      style: TextStyle(
                        color: _startDate != null 
                            ? theme.colorScheme.onSurface 
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Status Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Trip Status',
                    prefixIcon: const Icon(Icons.flag_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: ['Upcoming', 'Completed', 'Cancelled']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedStatus = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _notesController,
                  label: 'Travel Notes / Details',
                  hint: 'Describe your favorite moments...',
                  prefixIcon: Icons.note_alt_outlined,
                ),
                const SizedBox(height: 28),

                tripProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.bookmark_added_rounded),
                        label: const Text('Save Trip Itinerary'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
