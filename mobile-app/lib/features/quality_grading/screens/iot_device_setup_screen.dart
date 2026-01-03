import 'package:flutter/material.dart';

// Main selection page - choose instruction type
class IotDeviceSetupScreen extends StatelessWidget {
  const IotDeviceSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "IoT Device Setup",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                "Choose Your Setup Guide",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Text + Images Option
              Expanded(
                child: _InstructionCard(
                  icon: Icons.menu_book_rounded,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  title: "Step-by-Step Guide",
                  subtitle: "Written instructions with images",
                  features: const [
                    "Clear step-by-step process",
                    "Detailed images for each step",
                    "Easy to follow at your own pace",
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TextInstructionsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Video Option
              Expanded(
                child: _InstructionCard(
                  icon: Icons.play_circle_filled_rounded,
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  title: "Video Tutorial",
                  subtitle: "Watch and learn visually",
                  features: const [
                    "Complete demonstration",
                    "Real-time setup walkthrough",
                    "Pause and replay anytime",
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VideoInstructionsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Instruction card widget
class _InstructionCard extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final List<String> features;
  final VoidCallback onTap;

  const _InstructionCard({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Start Learning",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Text + Images Instructions Screen
class TextInstructionsScreen extends StatefulWidget {
  const TextInstructionsScreen({super.key});

  @override
  State<TextInstructionsScreen> createState() => _TextInstructionsScreenState();
}

class _TextInstructionsScreenState extends State<TextInstructionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Power On the Device',
      'description': 'Connect your ESP32 device to power using the provided USB cable or battery pack.',
      'icon': Icons.power_settings_new_rounded,
      'color': Colors.green,
      'details': [
        'Ensure the battery is charged or USB is connected',
        'The power LED should light up (usually red or blue)',
        'Wait 5-10 seconds for the device to initialize',
      ],
      'tips': 'If the LED doesn\'t turn on, check the battery connection or try a different USB cable.',
    },
    {
      'title': 'Enable Bluetooth',
      'description': 'Turn on Bluetooth on your smartphone to allow device pairing.',
      'icon': Icons.bluetooth_rounded,
      'color': Colors.blue,
      'details': [
        'Go to your phone Settings',
        'Navigate to Bluetooth settings',
        'Turn Bluetooth ON',
        'Keep the Bluetooth settings screen open',
      ],
      'tips': 'Make sure you\'re within 10 meters of the device for best connectivity.',
    },
    {
      'title': 'Search for Device',
      'description': 'The app will automatically search for nearby ESP32 devices.',
      'icon': Icons.search_rounded,
      'color': Colors.orange,
      'details': [
        'Return to the app and tap "Connect Device"',
        'The app will scan for available devices',
        'This may take 10-15 seconds',
        'A list of nearby devices will appear',
      ],
      'tips': 'If the device doesn\'t appear, try restarting your ESP32 and scanning again.',
    },
    {
      'title': 'Select Your Device',
      'description': 'Choose "Pepper-Scale-XXXX" from the list of available devices.',
      'icon': Icons.devices_rounded,
      'color': Colors.purple,
      'details': [
        'Look for a device named "Pepper-Scale-XXXX"',
        'The XXXX represents your unique device ID',
        'Tap on the device name to connect',
        'You may need to confirm pairing',
      ],
      'tips': 'The device name is also printed on a label on the back of your ESP32 unit.',
    },
    {
      'title': 'Prepare the Container',
      'description': 'Place the standard 1L measuring cup on the sensor platform.',
      'icon': Icons.coffee_rounded,
      'color': Colors.brown,
      'details': [
        'Use only the provided 1L measuring cup',
        'Center the cup on the load cell platform',
        'Ensure the cup sits flat and stable',
        'Wait for the display to show "0.0g" (tare)',
      ],
      'tips': 'The container must be clean and completely dry for accurate readings.',
    },
    {
      'title': 'Fill with Sample',
      'description': 'Fill the cup with your pepper sample up to the 1L mark.',
      'icon': Icons.water_drop_rounded,
      'color': Colors.teal,
      'details': [
        'Pour pepper slowly to avoid spilling',
        'Fill exactly to the 1L line on the cup',
        'Gently tap the sides to settle the pepper',
        'Avoid compressing or shaking excessively',
      ],
      'tips': 'For best results, use pepper that\'s been properly dried and cleaned.',
    },
    {
      'title': 'Wait for Reading',
      'description': 'Allow 15-20 seconds for the measurement to stabilize.',
      'icon': Icons.hourglass_bottom_rounded,
      'color': Colors.amber,
      'details': [
        'Keep the device on a stable, level surface',
        'Don\'t touch or move the device',
        'Watch the app screen for the reading',
        'The measurement will appear automatically',
      ],
      'tips': 'If the reading keeps changing, the surface may not be level or stable.',
    },
    {
      'title': 'Record & Continue',
      'description': 'The bulk density value is now recorded. Proceed to take photos.',
      'icon': Icons.check_circle_rounded,
      'color': Colors.green,
      'details': [
        'The app will show your bulk density (g/L)',
        'This value is automatically saved',
        'You can now proceed to image capture',
        'Tap "Continue to Photo Capture" when ready',
      ],
      'tips': 'You can always return to view this measurement in your batch details.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Setup Instructions",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Step ${_currentPage + 1} of ${_steps.length}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      "${((_currentPage + 1) / _steps.length * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _steps.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: (step['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            size: 64,
                            color: step['color'] as Color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        step['description'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Details
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Detailed Steps:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...(step['details'] as List<String>).asMap().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: (step['color'] as Color).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${entry.key + 1}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: step['color'] as Color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tips
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_rounded,
                              color: Colors.amber.shade700,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pro Tip",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step['tips'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.amber.shade900,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Previous",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentPage == 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _steps.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Setup guide completed! You're ready to start."),
                            backgroundColor: Color(0xFF2E7D32),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage < _steps.length - 1 ? "Next" : "Done",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Video Instructions Screen
class VideoInstructionsScreen extends StatelessWidget {
  const VideoInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Video Tutorial",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Player Placeholder
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.black87,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.play_circle_filled_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "0:00 / 5:32",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Icon(Icons.fullscreen, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Complete IoT Device Setup",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "5 min 32 sec",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility_rounded, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "2.4K views",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Video chapters
                  Text(
                    "Video Chapters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _VideoChapter(
                    time: "0:00",
                    title: "Introduction",
                    icon: Icons.waving_hand_rounded,
                    color: Colors.blue,
                  ),
                  _VideoChapter(
                    time: "0:45",
                    title: "Unboxing & Components",
                    icon: Icons.inventory_2_rounded,
                    color: Colors.orange,
                  ),
                  _VideoChapter(
                    time: "1:30",
                    title: "Powering On the Device",
                    icon: Icons.power_settings_new_rounded,
                    color: Colors.green,
                  ),
                  _VideoChapter(
                    time: "2:15",
                    title: "Bluetooth Connection",
                    icon: Icons.bluetooth_rounded,
                    color: Colors.indigo,
                  ),
                  _VideoChapter(
                    time: "3:20",
                    title: "Taking Measurements",
                    icon: Icons.science_rounded,
                    color: Colors.purple,
                  ),
                  _VideoChapter(
                    time: "4:45",
                    title: "Troubleshooting Tips",
                    icon: Icons.build_rounded,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 24),

                  // Additional resources
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade400, Colors.teal.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.download_rounded, color: Colors.white, size: 32),
                          const SizedBox(height: 12),
                          const Text(
                            "Download Setup PDF",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Get a printable version of the complete setup guide",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Downloading PDF guide...")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.file_download_rounded),
                                SizedBox(width: 8),
                                Text(
                                  "Download Now",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Need help section
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.support_agent_rounded, size: 32, color: Colors.grey[700]),
                          const SizedBox(height: 12),
                          Text(
                            "Need Help?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Contact our support team for assistance",
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Opening support chat...")),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline_rounded),
                            label: const Text("Contact Support"),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoChapter extends StatelessWidget {
  final String time;
  final String title;
  final IconData icon;
  final Color color;

  const _VideoChapter({
    required this.time,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Seeking to $time - $title")),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_arrow_rounded, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}