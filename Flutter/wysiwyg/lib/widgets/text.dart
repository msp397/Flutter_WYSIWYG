import 'package:flutter/material.dart';

class TextWidget extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final FontWeight fontWeight;
  final String textTheme;
  final TextOverflow textOverflow;
  final TextAlign textAlign;
  final String? foregroundColor;
  final List<Map<String, dynamic>>? animationConfig;

  const TextWidget({
    super.key,
    this.text = 'Lord Muruga',
    this.textStyle,
    this.textTheme = 'labelMedium',
    this.textOverflow = TextOverflow.fade,
    this.textAlign = TextAlign.center,
    this.fontWeight = FontWeight.w100, 
    this.foregroundColor, 
    this.animationConfig = const [],
  });

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget>  with TickerProviderStateMixin {

  // Linear Gradient
  Gradient? linearGradient;

  // Animation 
  late AnimationController _controller;
  Animation<double>? _fadeAnim;
  bool _isFadAnimating = false;
  Animation<Offset>? _slideAnim;
  bool _isSlideAnimating = false;
  Animation<double>? _scaleAnim;
  bool _isScaleAnimating = false;
  Animation<double>? _rotateAnim;
  bool _isRotateAnimating = false;

  @override
  void initState(){
    super.initState();
    _setupAnimations();
  }


   void _setupAnimations() {    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final curves = {
      "ease in": Curves.easeIn,
      "ease in out": Curves.easeInOut,
      "ease out": Curves.easeOut,
      "bounce": Curves.bounceOut,
      "elastic": Curves.elasticOut,
      "linear": Curves.linear,
    };

    if (widget.animationConfig != null) {
      for (final anim in widget.animationConfig!) {
        if (anim["value"] == true) {
          switch (anim["name"]) {
            case "fade":
              setState(() {
                _isFadAnimating = true;
                final props = anim["fadeProps"];
                _fadeAnim = Tween<double>(
                  begin: (props["initialOpacity"]["value"] ?? 0).toDouble(),
                  end: (props["finalOpacity"]["value"] ?? 1).toDouble(),
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve:
                      curves[props["animationCurve"]["value"]] ?? Curves.linear,
                ));
              });
              break;
            case "slide":
              setState(() {
                _isSlideAnimating = true;
                final props = anim["slideProps"];
                _slideAnim = Tween<Offset>(
                  begin: Offset(
                    (props["horizontalSlide"][0]["value"] ?? 0).toDouble(),
                    (props["verticalSlide"][0]["value"] ?? 0).toDouble(),
                  ),
                  end: Offset(
                    (props["horizontalSlide"][1]["value"] ?? 0).toDouble(),
                    (props["verticalSlide"][1]["value"] ?? 0).toDouble(),
                  ),
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve: curves[props["animationCurve"]["value"]] ?? Curves.linear,
                ));
              });
              break;
            case "scale":
              setState(() {
                _isScaleAnimating = true;
                final props = anim["scaleProps"];
                _scaleAnim = Tween<double>(
                  begin: (props["initialScale"][0]["value"] ?? 1).toDouble(),
                  end: (props["finalScale"][0]["value"] ?? 1).toDouble(),
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve:
                      curves[props["animationCurve"]["value"]] ?? Curves.linear,
                ));
              });
              break;
            case "roate":
              setState(() {
                _isRotateAnimating = true;
                final props = anim["roateProps"];
                _rotateAnim = Tween<double>(
                  begin: (props["initialTurn"]["value"] ?? 0).toDouble(),
                  end: (props["finalTurn"]["value"] ?? 0).toDouble(),
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve:
                      curves[props["animationCurve"]["value"]] ?? Curves.linear,
                ));
              });
              break;
          }
        }
      }
    }

    _controller.forward();
  }

   String maskAmount(String value, {bool show = false}) {
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    return show ? value : '*' * cleaned.length;
  }

  Widget _applyAnimations(Widget child) {
    Widget animated = child;

    if (_fadeAnim != null && _isFadAnimating) {
      animated = FadeTransition(opacity: _fadeAnim!, child: animated);
    }
    if (_slideAnim != null && _isSlideAnimating) {
      animated = SlideTransition(position: _slideAnim!, child: animated);
    }
    if (_scaleAnim != null && _isScaleAnimating) {
      animated = ScaleTransition(scale: _scaleAnim!, child: animated);
    }
    if (_rotateAnim != null && _isRotateAnimating) {
      animated = RotationTransition(turns: _rotateAnim!, child: animated);
    }

    return animated;
  }





  @override
  Widget build(BuildContext context) {

    TextStyle themeTextStyle = _getTextThemeStyle(widget.textTheme);

    Color textColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.foregroundColor) {
      case "primary":
        textColor = Theme.of(context).colorScheme.primary;
        break;
      case "secondary":
        textColor = Theme.of(context).colorScheme.secondary;
        break;
      case "tertiary":
        textColor = Theme.of(context).colorScheme.tertiary;
        break;
      case "transparent":
        textColor = Colors.transparent;
        break;
      case "light":
        textColor = isDark ? Colors.white : Colors.black;
        break;
      case "dark":
        textColor = isDark ? Colors.white70 : Colors.black;
        break;
      case "greyShade":
        textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade800;
        break;
       
      default:
        textColor = isDark ? Colors.white : Colors.black;
        break;
    }

      final effectiveStyle = widget.textStyle ??
      themeTextStyle.copyWith(
        color: linearGradient == null ? textColor : null,
        foreground: linearGradient != null ? (Paint()
              ..shader = linearGradient!.createShader(
                const Rect.fromLTWH(0, 0, 200, 70),
              ))
            : null,
    );

    return _applyAnimations(
       Visibility(
        visible: true,
        child: GestureDetector(
          child: Text(
            widget.text,
            overflow: widget.textOverflow,
            textAlign: widget.textAlign,
            style: widget.textStyle != null ? widget.textStyle : effectiveStyle,
          ),
        ),
      ),
    );
  }

  TextStyle _getTextThemeStyle(String theme) {
    switch (theme) {
      case 'displayLarge':
        return TextStyle(fontSize: 57, fontWeight: widget.fontWeight);
      case 'displayMedium':
        return TextStyle(fontSize: 45, fontWeight: widget.fontWeight);
      case 'displaySmall':
        return TextStyle(fontSize: 36, fontWeight: widget.fontWeight);
      case 'headlineLarge':
        return TextStyle(fontSize: 32, fontWeight: widget.fontWeight);
      case 'headlineMedium':
        return TextStyle(fontSize: 28, fontWeight: widget.fontWeight);
      case 'headlineSmall':
        return TextStyle(fontSize: 24, fontWeight: widget.fontWeight);
      case 'titleLarge':
        return TextStyle(fontSize: 22, fontWeight: widget.fontWeight);
      case 'titleMedium':
        return TextStyle(fontSize: 16, fontWeight: widget.fontWeight);
      case 'titleSmall':
        return TextStyle(fontSize: 14, fontWeight: widget.fontWeight);
      case 'labelLarge':
        return TextStyle(fontSize: 14, fontWeight: widget.fontWeight);
      case 'labelMedium':
        return TextStyle(fontSize: 12, fontWeight: widget.fontWeight);
      case 'labelSmall':
        return TextStyle(fontSize: 11, fontWeight: widget.fontWeight);
      case 'bodyLarge':
        return TextStyle(fontSize: 16, fontWeight: widget.fontWeight);
      case 'bodyMedium':
        return TextStyle(fontSize: 14, fontWeight: widget.fontWeight);
      case 'bodySmall':
        return TextStyle(fontSize: 12, fontWeight: widget.fontWeight);
      default:
        return TextStyle(fontSize: 12, fontWeight: widget.fontWeight);
    }
  }
}
