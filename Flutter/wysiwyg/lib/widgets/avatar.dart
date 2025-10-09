import 'package:flutter/material.dart';

class TAvatar extends StatefulWidget {
  final String? text;
  final String size;
  final String? imageUrl;
  final IconData? icon;
  final String? foregroundColor;
  final String? backgroundColor;
  final VoidCallback? callback;
  final List<Map<String, dynamic>>? animationConfig;

  const TAvatar({
    super.key,
    this.text,
    this.size = 'small',
    this.imageUrl,
    this.icon, 
    this.foregroundColor, 
    this.backgroundColor, 
    this.callback, 
    this.animationConfig,
  });

  @override
  State<TAvatar> createState() => _TAvatarState();
}

class _TAvatarState extends State<TAvatar> with TickerProviderStateMixin  {

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
  
  double _getRadius(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    switch (widget.size) {
      case 'small':
        return screenWidth * 0.06;
      case 'medium':
        return screenWidth * 0.08;
      case 'large':
        return screenWidth * 0.12;
      default:
        return screenWidth * 0.08;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (widget.size) {
      case 'small':
        return Theme.of(context).textTheme.headlineSmall!;  
      case 'medium':
        return Theme.of(context).textTheme.headlineMedium!; 
      case 'large':
        return Theme.of(context).textTheme.headlineLarge!; 
      default:
        return Theme.of(context).textTheme.headlineSmall!; 
    }
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
   

  Color avatarbackgroundcolor = Colors.transparent;

    switch (widget.backgroundColor) {
      case 'primary':
        avatarbackgroundcolor = Theme.of(context).colorScheme.primaryContainer;
        break;
      case 'secondary':
        avatarbackgroundcolor = Theme.of(context).colorScheme.secondary;
        break;
      case 'tertiary':
        avatarbackgroundcolor = Theme.of(context).colorScheme.tertiary;
        break;
      case 'transparent':
        avatarbackgroundcolor = Colors.transparent;
        break;
      case 'light':
        avatarbackgroundcolor = Colors.white;
        break;
      case 'dark':
        avatarbackgroundcolor = Colors.black;
        break;
      case 'greyShade':
        avatarbackgroundcolor = Colors.grey.shade200;
        break;
      default:
        avatarbackgroundcolor = Colors.transparent;
        break;
    }

     Color avatarforegroundcolor = Colors.black;
    switch (widget.foregroundColor) {
      case "primary":
        avatarforegroundcolor = Theme.of(context).colorScheme.primary;
        break;
      case "secondary":
        avatarforegroundcolor = Theme.of(context).colorScheme.secondary;
        break;
      case "tertiary":
        avatarforegroundcolor = Theme.of(context).colorScheme.tertiary;
        break;
      case "transparent":
        avatarforegroundcolor = Colors.transparent;
        break;
      case "light":
        avatarforegroundcolor = Colors.white;
        break;
      case "dark":
        avatarforegroundcolor = Colors.black;
        break;
      case "greyShade":
        avatarforegroundcolor = Colors.grey.shade200;
        break;
      default:
        avatarforegroundcolor = Colors.transparent;
        break;
    }

     List<String> words = widget.text != null ? widget.text!.split(' ') : [];
    String initials = '';

    if (words.isNotEmpty) {
      initials += words[0][0].toUpperCase();
      
      if (words.length > 1) {
        initials += words.last[0].toUpperCase();
      }
    }

    ImageProvider? imageProvider;
    if (widget.imageUrl != null) {
      setState(() {
        if (widget.imageUrl!.contains('http') || widget.imageUrl!.contains('https')) {
          imageProvider = NetworkImage(widget.imageUrl!);
        } else {
          imageProvider = AssetImage(widget.imageUrl!);
        }
      });
    }
    
    return  _applyAnimations(
       Visibility(
        visible: true,
        child: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
            radius: _getRadius(context),
            backgroundImage: imageProvider,
            backgroundColor: avatarbackgroundcolor,
            foregroundColor: avatarforegroundcolor,
            child: widget.icon != null
                ? Icon(widget.icon)
                : initials.isNotEmpty
                    ? Text(
                        initials,
                        style: _getTextStyle(context),
                      )
                    : null,
            ),
        ),
      ),
    );
  }
}
