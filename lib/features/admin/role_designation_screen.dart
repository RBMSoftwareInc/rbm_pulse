import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_footer.dart';

class RoleDesignationScreen extends StatefulWidget {
  final String userId;
  final String currentRole;

  const RoleDesignationScreen({
    super.key,
    required this.userId,
    required this.currentRole,
  });

  @override
  State<RoleDesignationScreen> createState() => _RoleDesignationScreenState();
}

class _RoleDesignationScreenState extends State<RoleDesignationScreen> {
  String? _selectedRole;
  String? _selectedDesignation;
  List<Map<String, dynamic>> _designations = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
    _loadDesignations();
    _loadUserDesignation();
  }

  Future<void> _loadDesignations() async {
    try {
      final response = await Supabase.instance.client
          .from('designations')
          .select()
          .eq('is_active', true)
          .order('name');

      setState(() {
        _designations = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading designations: $e')),
        );
      }
    }
  }

  Future<void> _loadUserDesignation() async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('designation')
          .eq('id', widget.userId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _selectedDesignation = response['designation'] as String?;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _saveChanges() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await Supabase.instance.client.from('profiles').update({
        'role': _selectedRole,
        'designation': _selectedDesignation,
      }).eq('id', widget.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role and designation updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  List<Map<String, dynamic>> _getDesignationsForRole(String? role) {
    if (role == null) return [];
    return _designations.where((d) => d['role'] == role).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Role & Designation'),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1B1B1B), Color(0xFF2C2C2C)],
                ),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role Selection
                          const Text(
                            'Select Role',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              'employee',
                              'manager',
                              'leader',
                              'hr',
                              'admin',
                              'boss',
                            ].map((role) {
                              final isSelected = _selectedRole == role;
                              return FilterChip(
                                label: Text(role.toUpperCase()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedRole = selected ? role : null;
                                    _selectedDesignation = null;
                                  });
                                },
                                selectedColor: const Color(0xFFD72631),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),

                          // Designation Selection
                          if (_selectedRole != null) ...[
                            const Text(
                              'Select Designation',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._getDesignationsForRole(_selectedRole)
                                .map((designation) {
                              final code = designation['code'] as String;
                              final name = designation['name'] as String;
                              final description =
                                  designation['description'] as String?;
                              final isSelected = _selectedDesignation == code;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: isSelected
                                    ? const Color(0xFFD72631).withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                child: ListTile(
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: description != null
                                      ? Text(
                                          description,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                        )
                                      : null,
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle,
                                          color: Color(0xFFD72631))
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedDesignation = code;
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD72631),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}
