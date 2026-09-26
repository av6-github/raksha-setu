// lib/features/security/presentation/app_lock_screen.dart
// Screen for setting up, configuring, and testing local device PIN app lock

import 'package:flutter/material.dart';
import 'app_lock_view_model.dart';

class AppLockScreen extends StatefulWidget {
  final AppLockViewModel viewModel;

  const AppLockScreen({super.key, required this.viewModel});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override

  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Local Device App Lock'),
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              vm.isLockEnabled ? Icons.lock : Icons.lock_open,
                              size: 40,
                              color: vm.isLockEnabled ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vm.isLockEnabled ? 'App Lock is Active' : 'App Lock is Disabled',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    vm.isLockEnabled
                                        ? 'Requires PIN when reopening the app'
                                        : 'Protect your wellness check-ins from shoulder surfing',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!vm.isLockEnabled) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Setup 4-Digit Security PIN',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _pinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 4,
                                decoration: const InputDecoration(
                                  labelText: 'Enter 4-digit PIN',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.pin),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _confirmPinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 4,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm PIN',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.check),
                                ),
                              ),
                              if (vm.errorMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  vm.errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ],
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  if (_pinController.text != _confirmPinController.text) {
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('PINs do not match')),
                                    );
                                    return;
                                  }
                                  final success = await vm.setupPin(_pinController.text);
                                  if (!mounted) return;
                                  if (success) {
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('App Lock enabled successfully')),
                                    );
                                    _pinController.clear();
                                    _confirmPinController.clear();
                                  }
                                },


                                child: const Text('Enable App Lock'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Auto-Lock Timeout'),
                              subtitle: Text('Immediately on app exit or after ${vm.timeoutMinutes} minutes'),
                              trailing: const Icon(Icons.timer_outlined),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.lock_reset, color: Colors.orange),
                              title: const Text('Test Lock Now'),
                              subtitle: const Text('Simulate screen lock to verify PIN'),
                              onTap: () {
                                vm.lock();
                                _showUnlockDialog(context, vm);
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.delete_forever, color: Colors.red),
                              title: const Text('Disable App Lock', style: TextStyle(color: Colors.red)),
                              onTap: () async {
                                await vm.disableLock();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('App Lock disabled')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  void _showUnlockDialog(BuildContext context, AppLockViewModel vm) {
    final unlockController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.blue),
              SizedBox(width: 8),
              Text('Enter PIN to Unlock'),
            ],
          ),
          content: TextField(
            controller: unlockController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '4-digit PIN',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final success = await vm.unlockWithPin(unlockController.text);
                if (success && ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App unlocked successfully!')),
                  );
                } else if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect PIN')),
                  );
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }
}
