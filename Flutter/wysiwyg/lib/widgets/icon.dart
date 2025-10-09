import 'package:flutter/material.dart';

class TIcon extends StatefulWidget {
  final IconData icon;
  final String size; 
  final String? color;
  final Function()? onTap;
  final VoidCallback? callback;
  final List<Map<String, dynamic>>? animationConfig;

  const TIcon({
    super.key,
    this.icon = Icons.question_mark,
    this.size = 'medium', 
    this.color = 'primary',
    this.onTap,
    this.callback,
    this.animationConfig = const [],
  });

  @override
  State<TIcon> createState() => _TIconState();
}

class _TIconState extends State<TIcon>  with TickerProviderStateMixin {

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
         
    Color iconColor;
     switch(widget.color){
      case 'primary':
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case 'secondary':
        iconColor = Theme.of(context).colorScheme.secondary;
        break;
      case 'tertiary':
        iconColor = Theme.of(context).colorScheme.tertiary;
        break;
      case 'transparent':
        iconColor = Colors.transparent;
        break;
      default:
        iconColor = Theme.of(context).colorScheme.primary;
        break;
    }
    
    
    double iconSize;
    switch (widget.size) {
      case 'small':
        iconSize = 16.0;
        break;
      case 'large':
        iconSize = 32.0;
        break;
      case 'medium':
      default:
        iconSize = 24.0;
        break;
    }

    return _applyAnimations(
       Visibility(
        visible: true,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Icon(
            widget.icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
