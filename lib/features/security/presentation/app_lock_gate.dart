// lib/features/security/presentation/app_lock_gate.dart
// Full-screen biometric and PIN lock gate triggered on app cold start and resume

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/app_lock_service.dart';
import '../../auth/presentation/auth_view_model.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;
  final IAppLockService appLockService;

  const AppLockGate({
    super.key,
    required this.child,
    required this.appLockService,
  });

  @override
  State<AppLockGate> createState() => AppLockGateState();
}

class AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _isLocked = false;
  String _enteredPin = '';
  String? _errorMessage;
  bool _isVerifying = false;
  String? _lockedProfileKey;

  AuthViewModel? _authVm;
  String? _unlockedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = Provider.of<AuthViewModel?>(context);
    if (vm != _authVm) {
      _authVm?.removeListener(_handleAuthChange);
      _authVm = vm;
      _authVm?.addListener(_handleAuthChange);
      _handleAuthChange();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authVm?.removeListener(_handleAuthChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final user = _authVm?.currentUser;
      if (user != null) {
        final profileKey = user.email ?? user.id;
        widget.appLockService.isAppLockEnabled(profileKey: profileKey).then((enabled) {
          if (enabled && mounted) {
            setState(() {
              _isLocked = true;
              _unlockedUserId = null;
              _lockedProfileKey = profileKey;
              _enteredPin = '';
              _errorMessage = null;
            });
          }
        });
      }
    }
  }

  void _handleAuthChange() async {
    final user = _authVm?.currentUser;
    if (user == null) {
      if (_isLocked || _unlockedUserId != null) {
        setState(() {
          _isLocked = false;
          _unlockedUserId = null;
          _lockedProfileKey = null;
          _enteredPin = '';
          _errorMessage = null;
        });
      }
      return;
    }

    final userKey = user.email ?? user.id;
    if (_unlockedUserId != userKey) {
      final enabled = await widget.appLockService.isAppLockEnabled(profileKey: userKey);
      if (enabled && mounted) {
        setState(() {
          _isLocked = true;
          _lockedProfileKey = userKey;
          _enteredPin = '';
          _errorMessage = null;
        });
      } else if (!enabled) {
        _unlockedUserId = userKey;
      }
    }
  }

  void lockImmediately() {
    final user = _authVm?.currentUser;
    if (user != null) {
      setState(() {
        _isLocked = true;
        _unlockedUserId = null;
        _lockedProfileKey = user.email ?? user.id;
        _enteredPin = '';
        _errorMessage = null;
      });
    }
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length >= 4 || _isVerifying) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += digit;
      _errorMessage = null;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty && !_isVerifying) {
      HapticFeedback.selectionClick();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _onClearPressed() {
    if (!_isVerifying) {
      HapticFeedback.selectionClick();
      setState(() {
        _enteredPin = '';
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final authVm = context.read<AuthViewModel?>();
    final user = authVm?.currentUser;
    final profileKey = _lockedProfileKey ?? user?.email ?? user?.id;

    setState(() {
      _isVerifying = true;
    });

    final isValid = await widget.appLockService.verifyPin(_enteredPin, profileKey: profileKey);

    if (!mounted) return;

    if (isValid) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isLocked = false;
        _unlockedUserId = profileKey;
        _enteredPin = '';
        _errorMessage = null;
        _isVerifying = false;
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _enteredPin = '';
        _errorMessage = 'Incorrect profile PIN. Try again.';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel?>();
    final user = authVm?.currentUser;

    // Do not lock if user is not authenticated or not locked
    if (!_isLocked || user == null) {
      return widget.child;
    }

    final profileKey = _lockedProfileKey ?? user.email ?? user.id;
    final defaultPin = widget.appLockService.getDefaultPinForProfile(profileKey);

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Deep tactical navy
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Raksha Security Emblem & Title
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.shade700.withValues(alpha: 0.15),
                border: Border.all(color: Colors.amber.shade600, width: 2),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 56,
                color: Color(0xFFE2B714),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Profile Security Lock • ${user.role.name.toUpperCase()}',
              style: TextStyle(
                color: Colors.amber.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Default PIN: $defaultPin (Master: 2026)',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 28),

            // PIN Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? (_errorMessage != null ? Colors.redAccent : const Color(0xFFE2B714))
                        : Colors.white24,
                    border: Border.all(
                      color: isFilled
                          ? (_errorMessage != null ? Colors.redAccent : const Color(0xFFE2B714))
                          : Colors.white54,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Error message or verification spinner
            SizedBox(
              height: 24,
              child: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                    )
                  : (_errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const SizedBox.shrink()),
            ),

            const Spacer(flex: 1),

            // Numeric Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  _buildBottomKeypadRow(),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Sign out button
            TextButton.icon(
              onPressed: () async {
                setState(() {
                  _isLocked = false;
                  _enteredPin = '';
                  _lockedProfileKey = null;
                });
                await authVm?.signOut();
              },
              icon: const Icon(Icons.logout, size: 16, color: Colors.white60),
              label: const Text(
                'Switch Profile / Sign Out',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKeypadButton(d)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white12, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomKeypadRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Clear Button
        InkWell(
          onTap: _onClearPressed,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            child: const Text(
              'CLR',
              style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Digit 0
        _buildKeypadButton('0'),
        // Backspace Button
        InkWell(
          onTap: _onBackspacePressed,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            child: const Icon(Icons.backspace_outlined, color: Colors.white70, size: 24),
          ),
        ),
      ],
    );
  }
}
