import 'package:flutter/material.dart';

List<String> progressBarSize = [ 'small', 'medium', 'large', 'max' ];

class TProgressbar extends StatefulWidget {
  final double? value;  
  final String type;  
  final Color color;
  final Color backgroundColor;
  final String size;
  final List<Map<String, dynamic>>? animationConfig;

  const TProgressbar({
    super.key,
    this.value,
    this.size = 'block',
    this.type = 'circular ',
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.animationConfig = const [],
   
  });

  @override
  State<TProgressbar> createState() => _TProgressbarState();
}

class _TProgressbarState extends State<TProgressbar> with TickerProviderStateMixin {

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
    double progressBarSize = _getSize();
       Color progressColor;
    Color backgroundColor;

     switch(widget.color){
      case 'primary':
        progressColor = Theme.of(context).colorScheme.primary;
        break;
      case 'secondary':
        progressColor = Theme.of(context).colorScheme.secondary;
        break;
      case 'tertiary':
        progressColor = Theme.of(context).colorScheme.tertiary;
        break;
      case 'transparent':
        progressColor = Colors.transparent;
        break;
      case 'light':
        progressColor = Colors.white;
        break;
      case 'dark':
        progressColor = Colors.black;
        break;
      case 'greyShade':
        progressColor = Colors.grey.shade200;
        break;
      default:
        progressColor = Theme.of(context).colorScheme.primary;
        break;
    }

     switch(widget.backgroundColor){
      case 'primary':
        backgroundColor = Theme.of(context).colorScheme.primary;
        break;
      case 'secondary':
        backgroundColor = Theme.of(context).colorScheme.secondary;
        break;
      case 'tertiary':
        backgroundColor = Theme.of(context).colorScheme.tertiary;
        break;
      case 'transparent':
        backgroundColor = Colors.transparent;
        break;
      case 'light':
        backgroundColor = Colors.white;
        break;
      case 'dark':
        backgroundColor = Colors.black;
        break;
      case 'greyShade':
        backgroundColor = Colors.grey.shade200;
        break;  
      default:
        backgroundColor = Theme.of(context).colorScheme.primary;
        break;
    }

    if (widget.type == 'linear') {
      return _applyAnimations(
         Visibility(
          visible: true,
          child: SizedBox(
            width: progressBarSize,
            height: 14.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: widget.value != null ? widget.value!.clamp(0.0, 1.0) : 0.0,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                backgroundColor: widget.backgroundColor,
              ),
            ),
          ),
        ),
      );
    }

    return _applyAnimations(
     Visibility(
        visible: true,
        child: SizedBox(
          width: progressBarSize,
          height: 14.0,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.backgroundColor),
                  strokeWidth: 8.0,
                  backgroundColor: Colors.transparent,
                ),
                CircularProgressIndicator(
                  value: widget.value != null ? widget.value!.clamp(0.0, 1.0) : 0.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  strokeWidth: 8.0,
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getSize() {
    switch (widget.size) {
      case 'small':
        return 30.0;
      case 'medium':
        return 70.0;
      case 'large':
        return 100.0;
      case 'max':
        return double.infinity;
      default:
        return 50.0;
    }
  }
}
