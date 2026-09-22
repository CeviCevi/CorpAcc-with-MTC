import 'package:flutter/material.dart';

class AppColor {
  static Color primary = Colors.deepPurple;
  static Color primaryDark = Color(0xff3f2a7a);
  static Color surface = Color(0xff1e1e1e);
  static Color surfaceAlt = Color(0xff2a2a2a);
  static Color white = Colors.white;
  static Color error = Color(0xffef5350);
}

class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  bool _switchValue = true;
  bool _checkboxValue = false;
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buttonsColumn()),
            const SizedBox(width: 16),
            Expanded(child: _inputsColumn()),
            const SizedBox(width: 16),
            Expanded(child: _controlsColumn()),
            const SizedBox(width: 16),
            Expanded(child: _cardsAndAlertsColumn()),
          ],
        ),
      ),
    );
  }

  Widget _buttonsColumn() {
    return _panel(
      title: 'Кнопки',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Primary'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.primary,
              side: BorderSide(color: AppColor.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Outlined'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: AppColor.primary),
            child: const Text('Text'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.surfaceAlt,
              foregroundColor: AppColor.white.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Disabled'),
          ),
        ],
      ),
    );
  }

  Widget _inputsColumn() {
    return _panel(
      title: 'Поля ввода',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            style: TextStyle(color: AppColor.white),
            decoration: InputDecoration(
              hintText: 'Обычное поле',
              hintStyle: TextStyle(color: AppColor.white.withOpacity(0.5)),
              filled: true,
              fillColor: AppColor.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            enabled: false,
            style: TextStyle(color: AppColor.white),
            decoration: InputDecoration(
              hintText: 'Отключено',
              hintStyle: TextStyle(color: AppColor.white.withOpacity(0.3)),
              filled: true,
              fillColor: AppColor.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            style: TextStyle(color: AppColor.white),
            decoration: InputDecoration(
              hintText: 'С ошибкой',
              hintStyle: TextStyle(color: AppColor.error.withOpacity(0.6)),
              filled: true,
              fillColor: AppColor.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlsColumn() {
    return _panel(
      title: 'Элементы',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Switch(
                value: _switchValue,
                activeColor: AppColor.primary,
                onChanged: (v) => setState(() => _switchValue = v),
              ),
              const SizedBox(width: 8),
              Text('Switch', style: TextStyle(color: AppColor.white)),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: _checkboxValue,
                activeColor: AppColor.primary,
                checkColor: AppColor.white,
                onChanged: (v) => setState(() => _checkboxValue = v ?? false),
              ),
              const SizedBox(width: 8),
              Text('Checkbox', style: TextStyle(color: AppColor.white)),
            ],
          ),
          Row(
            children: [
              Radio<int>(
                value: 1,
                groupValue: 1,
                activeColor: AppColor.primary,
                onChanged: (_) {},
              ),
              const SizedBox(width: 8),
              Text('Radio', style: TextStyle(color: AppColor.white)),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _sliderValue,
            activeColor: AppColor.primary,
            inactiveColor: AppColor.surfaceAlt,
            onChanged: (v) => setState(() => _sliderValue = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Активно',
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardsAndAlertsColumn() {
    return _panel(
      title: 'Карточки и уведомления',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _miniCard(icon: Icons.person, title: 'Профиль'),
          const SizedBox(height: 8),
          _miniCard(icon: Icons.settings, title: 'Настройки'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.primary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColor.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Информация',
                    style: TextStyle(color: AppColor.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.error.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColor.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ошибка',
                    style: TextStyle(color: AppColor.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCard({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.surfaceAlt),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColor.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: AppColor.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.surfaceAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColor.primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
