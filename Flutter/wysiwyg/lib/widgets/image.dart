import 'package:flutter/material.dart';

class TImage extends StatefulWidget {
  final String? imageUrl;
  final String size;
  final Function()? onTap;
  final VoidCallback? callback;
  final List<Map<String, dynamic>>? animationConfig;

  const TImage({
    super.key,
    this.imageUrl = 'https://images.squarespace-cdn.com/content/v1/60f1a490a90ed8713c41c36c/1629223610791-LCBJG5451DRKX4WOB4SP/37-design-powers-url-structure.jpeg?format=2500w',
    this.size = 'medium',
    this.onTap,
    this.callback,
    this.animationConfig = const [],
    
  });

  @override
  State<TImage> createState() => _TImageState();
}

class _TImageState extends State<TImage> with TickerProviderStateMixin {

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
    double imageSize;
    String? type;
    if (widget.imageUrl!.contains('http') ||
        widget.imageUrl!.contains('https')) {
      setState(() {
        type = 'network';
      });
    } else {
      setState(() {
        type = 'asset';
      });
    }
    switch (widget.size) {
      case 'small':
        imageSize = 24.0;
        break;
      case 'large':
        imageSize = 48.0;
        break;
      case 'medium':
      default:
        imageSize = 36.0;
        break;
    }

    return _applyAnimations(
      Visibility(
        visible: true,
        child: GestureDetector(
          onTap: widget.onTap,
          child: type == 'asset' && type != null
              ? Image.asset(
                  widget.imageUrl ?? 'assets/image/upload.png',
                  width: imageSize != 0 ? imageSize : null,
                  height: imageSize != 0 ? imageSize : null,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Icon(
                      Icons.error,
                      size: imageSize != 0 ? imageSize : 20,
                      color: Colors.red,
                    );
                  }
                )
              : type == 'network' && type != null
                  ? Image.network(
                      widget.imageUrl ?? '',
                      width: imageSize != 0 ? imageSize : null,
                      height: imageSize != 0 ? imageSize : null,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Icon(
                          Icons.error,
                          size: imageSize != 0 ? imageSize : 20,
                          color: Colors.red,
                        );
                      }
                    )
                  : Container(),
        ),
      ),
    );
  }
}
