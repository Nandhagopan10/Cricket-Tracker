import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:hive_flutter/hive_flutter.dart';

import '../../core/data/profiles_repository.dart';
import '../../core/models/profile.dart';
import '../../routes/app_routes.dart';

class ProfilesListScreen extends StatefulWidget {
  const ProfilesListScreen({super.key});

  @override
  State<ProfilesListScreen> createState() => _ProfilesListScreenState();
}

class _ProfilesListScreenState extends State<ProfilesListScreen> {
  final ProfilesRepository _repo = ProfilesRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.createProfile);
              setState(() {}); // Avoid unused result
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Profile>(
          ProfilesRepository.boxName,
        ).listenable(),
        builder: (context, Box<Profile> box, _) {
          final profiles = box.values.toList();
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No profiles yet'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.createProfile),
                    child: const Text('Create profile'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: profiles.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = profiles[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: p.avatarUrl != null
                      ? (p.avatarUrl!.startsWith('http')
                            ? CachedNetworkImageProvider(p.avatarUrl!)
                                  as ImageProvider
                            : FileImage(File(p.avatarUrl!)) as ImageProvider)
                      : null,
                  child: p.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(p.name),
                subtitle: Text(p.role),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (p.isDefault)
                      const Icon(Icons.check_circle, color: Colors.green),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.createProfile,
                            arguments: p,
                          );
                          if (!mounted) return;
                          setState(() {});
                        } else if (v == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Delete profile'),
                              content: const Text(
                                'Are you sure you want to delete this profile?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await _repo.deleteProfile(p.id);
                          }
                        } else if (v == 'default') {
                          await _repo.setDefaultProfile(p.id);
                          if (!mounted) return;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'default',
                          child: Text('Set as default'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  // Show profile details
                  showModalBottomSheet(
                    context: context,
                    builder: (c) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundImage: p.avatarUrl != null
                                    ? (p.avatarUrl!.startsWith('http')
                                          ? CachedNetworkImageProvider(
                                                  p.avatarUrl!,
                                                )
                                                as ImageProvider
                                          : FileImage(File(p.avatarUrl!))
                                                as ImageProvider)
                                    : null,
                                child: p.avatarUrl == null
                                    ? const Icon(Icons.person, size: 36)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(p.role),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Created: ${p.createdAt.toLocal()}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _repo.setDefaultProfile(p.id);
                                  if (!mounted) return;
                                  Navigator.pop(c);
                                },
                                child: const Text('Set Default'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
