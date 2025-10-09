import 'package:flutter/material.dart';

class TChip extends StatefulWidget {
  final String type; 
  final IconData? icon;
  final String label;
  final String? backgroundcolor;
  final VoidCallback? callback;
  final String? foregroundcolor;
  final List<Map<String, dynamic>>? animationConfig;

  const TChip({
    super.key,
    this.type = 'capsule',
    this.icon = Icons.add, 
    this.label = '', 
    this.backgroundcolor,
    this.callback, 
    this.foregroundcolor,
    this.animationConfig, 
  });

  @override
  State<TChip> createState() => _TChipState();
}

class _TChipState extends State<TChip> with TickerProviderStateMixin {

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
    BorderRadiusGeometry borderRadius;

    switch (widget.type) {
      case 'capsule':
        borderRadius = BorderRadius.circular(50);
        break;
      case 'rectangle':
        borderRadius = BorderRadius.zero;
        break;
      case 'rounded':
      default:
        borderRadius = BorderRadius.circular(30);
        break;
    }

    Widget chipLabel;
    if (widget.icon != null && widget.label.isNotEmpty) {
      chipLabel = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon),
          SizedBox(width: 8),
          Text(widget.label),
        ],
      );
    } else if (widget.icon != null) {
      chipLabel = Icon(widget.icon);
    } else {
      chipLabel = Text(widget.label);
    }

    Color containerColor;
    switch (widget.backgroundcolor) {
      case 'primary':
        containerColor = Theme.of(context).colorScheme.primaryContainer;
        break;
      case 'secondary':
        containerColor = Theme.of(context).colorScheme.secondary;
        break;
      case 'tertiary':
        containerColor = Theme.of(context).colorScheme.tertiary;
        break;
      case 'transparent':
        containerColor = Colors.transparent;
        break;
      case 'light':
        containerColor = Colors.white;
        break;
      case 'dark':
        containerColor = Colors.black;
        break;
      case 'greyShade':
        containerColor = Colors.grey.shade200;
        break;
      default:
        containerColor = Colors.transparent;
        break;
    }

      Color chipforegroundcolor;
    switch (widget.foregroundcolor) {
      case "primary":
        chipforegroundcolor = Theme.of(context).colorScheme.primary;
        break;
      case "secondary":
        chipforegroundcolor = Theme.of(context).colorScheme.secondary;
        break;
      case "tertiary":
        chipforegroundcolor = Theme.of(context).colorScheme.tertiary;
        break;
      case "transparent":
        chipforegroundcolor = Colors.transparent;
        break;
      case "light":
        chipforegroundcolor = Colors.white;
        break;
      case "dark":
        chipforegroundcolor = Colors.black;
        break;
      case "greyShade":
        chipforegroundcolor = Colors.grey.shade200;
        break;
      default:
        chipforegroundcolor = Colors.transparent;
        break;
    }

    if (widget.icon != null && widget.label.isNotEmpty) {
      chipLabel = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: chipforegroundcolor),
          const SizedBox(width: 8),
          Text(widget.label, style: TextStyle(color: chipforegroundcolor)),
        ],
      );
    } else if (widget.icon != null) {
      chipLabel = Icon(widget.icon, color: chipforegroundcolor);
    } else {
      chipLabel = Text(widget.label);
    }


    return _applyAnimations(
       Visibility(
        visible: true,
        child: GestureDetector(
          onTap: () {},
          onDoubleTap: () {},
          onLongPress: () {},
          child: Chip(
            label: chipLabel,
            backgroundColor: containerColor,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
          ),
        ),
      ),
    );
  }
}
