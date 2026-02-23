import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/profile.dart';
import '../../core/data/profiles_repository.dart';

/// Create Profile Screen
/// Allows the user to create a profile using sample players as templates.
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'Batsman';
  int? _selectedSampleIndex;
  Profile? _editingProfile;
  bool _didInitFromArgs = false;

  final List<Map<String, String>> _samplePlayers = [
    {
      'name': 'Virat Kohli',
      'role': 'Batsman',
      'thumbnail':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1730d2460-1764771416491.png',
    },
    {
      'name': 'Jasprit Bumrah',
      'role': 'Bowler',
      'thumbnail':
          'https://img.rocket.new/generatedImages/rocket_gen_img_18603f7fb-1764692187655.png',
    },
    {
      'name': 'Rohit Sharma',
      'role': 'Batsman',
      'thumbnail':
          'https://img.rocket.new/generatedImages/rocket_gen_img_153ad4c62-1764781444747.png',
    },
    {
      'name': 'Ravindra Jadeja',
      'role': 'All-rounder',
      'thumbnail':
          'https://img.rocket.new/generatedImages/rocket_gen_img_137af7d96-1766600651209.png',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;
    setState(() {
      _pickedImagePath = file.path;
      _selectedSampleIndex = null; // clear sample when custom image chosen
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Profile) {
      _editingProfile = args;
      _nameController.text = _editingProfile!.name;
      _selectedRole = _editingProfile!.role;
      final avatar = _editingProfile!.avatarUrl;
      if (avatar != null) {
        if (avatar.startsWith('http')) {
          final idx = _samplePlayers.indexWhere(
            (s) => s['thumbnail'] == avatar,
          );
          if (idx >= 0) _selectedSampleIndex = idx;
        } else {
          _pickedImagePath = avatar;
        }
      }
    }
    _didInitFromArgs = true;
  }

  void _applySample(int index) {
    final sample = _samplePlayers[index];
    setState(() {
      _selectedSampleIndex = index;
      _nameController.text = sample['name'] ?? '';
      _selectedRole = sample['role'] ?? _selectedRole;
      _pickedImagePath = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final avatar =
        _pickedImagePath ??
        (_selectedSampleIndex != null
            ? _samplePlayers[_selectedSampleIndex!]['thumbnail']
            : null);

    final profile = Profile(
      id: _editingProfile?.id,
      name: _nameController.text.trim(),
      role: _selectedRole,
      avatarUrl: avatar,
      createdAt: _editingProfile?.createdAt,
      isDefault: _editingProfile?.isDefault ?? false,
    );

    await ProfilesRepository().saveProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _editingProfile == null ? 'Profile created' : 'Profile updated',
        ),
      ),
    );
    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    final roles = ['Batsman', 'Bowler', 'All-rounder', 'Wicketkeeper'];

    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a sample player to prefill the form',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _samplePlayers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final s = _samplePlayers[index];
                  final selected = index == _selectedSampleIndex;
                  return GestureDetector(
                    onTap: () => _applySample(index),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: selected ? 34 : 30,
                          backgroundImage: NetworkImage(s['thumbnail']!),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 88,
                          child: Text(
                            s['name']!,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: selected ? 13 : 12,
                              fontWeight: selected ? FontWeight.w700 : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _pickedImagePath != null
                      ? FileImage(File(_pickedImagePath!)) as ImageProvider
                      : (_selectedSampleIndex != null
                            ? NetworkImage(
                                _samplePlayers[_selectedSampleIndex!]['thumbnail']!,
                              )
                            : null),
                  child:
                      (_pickedImagePath == null && _selectedSampleIndex == null)
                      ? const Icon(Icons.person_outline)
                      : null,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose image'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pickedImagePath = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedRole = v);
                    },
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
