import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/logic/providers/local_auth_provider.dart';


class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.task_alt,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Task Manager',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Secure your tasks with authentication',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              // Error message if any
              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => authProvider.clearError(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Authentication Button
              if (authProvider.isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Authenticating...'),
                  ],
                )
              else if (authProvider.biometricAvailable)
                _buildBiometricButton(context, authProvider)
              else
                _buildFallbackButton(context, authProvider),

              const SizedBox(height: 24),

              // Development/Demo options
              _buildDemoOptions(context, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => authProvider.authenticate(),
          icon: const Icon(Icons.fingerprint, size: 24),
          label: const Text(
            'Authenticate with Biometrics',
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Use your fingerprint or face to unlock',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFallbackButton(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => authProvider.authenticate(),
          child: const Text('Continue to App'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap continue to access your tasks',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDemoOptions(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Development Options',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => authProvider.skipAuthentication(),
              child: const Text('Skip Authentication'),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () => authProvider.enableForDevelopment(),
              child: const Text('Enable Access'),
            ),
          ],
        ),
      ],
    );
  }
}