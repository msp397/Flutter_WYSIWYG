import 'package:flutter/material.dart';

List<String> contentPosition = ['left', 'right', 'top', 'bottom'];
List<String> checkboxShape = ['rounded', 'squared'];

class TCheckbox extends StatefulWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool isDisabled;
  final String contentPosition;
  final String checkboxShape;
  final VoidCallback? callback;
  final List<Map<String, dynamic>>? animationConfig;

  const TCheckbox({
    super.key,
    this.value,
    this.onChanged,
    this.label,
    this.isDisabled = false,
    this.contentPosition = 'right',
    this.checkboxShape = 'squared',
    this.callback,
    this.animationConfig = const [],
  });

  @override
  State<TCheckbox> createState() => _TCheckboxState();
}

class _TCheckboxState extends State<TCheckbox> with TickerProviderStateMixin {
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

  // Linear Gradient
  Gradient? linearGradient;

  @override
  void initState() {
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
                  curve:
                      curves[props["animationCurve"]["value"]] ?? Curves.linear,
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
    Widget checkboxWidget = _applyAnimations(
      Visibility(
        visible: true,
        child: Checkbox(
          value: widget.value,
          onChanged: widget.isDisabled ? null : widget.onChanged,
          shape: widget.checkboxShape == 'rounded'
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              : null,
        ),
      ),
    );

    switch (widget.contentPosition) {
      case 'left':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label ?? ''),
            checkboxWidget,
          ],
        );
      case 'right':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            checkboxWidget,
            Text(widget.label ?? ''),
          ],
        );
      case 'top':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label ?? ''),
            checkboxWidget,
          ],
        );
      case 'bottom':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            checkboxWidget,
            Text(widget.label ?? ''),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            checkboxWidget,
            Text(widget.label ?? ''),
          ],
        );
    }
  }
}
