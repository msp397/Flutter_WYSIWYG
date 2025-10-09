import 'package:flutter/material.dart';

class Dateinput extends StatefulWidget {
  final String type;
  // final String size;
  final String? hintText;
  final bool isDisabled;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final bool showCursor;
  final String? helperText;
  final Widget? prefix;
  final Widget? suffix;
  final bool needClear;
  final String? label;
  final String? fillColor;
  final bool isFloatLabel;
  final MainAxisAlignment? floatingLabelPosition;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final VoidCallback? callback;
  final double widthFactor;
  final List<Map<String, dynamic>>? animationConfig;

  const Dateinput({
      super.key,
      this.type = '',
      this.hintText,
      this.isDisabled = false,
      this.textAlign = TextAlign.center,
      this.textAlignVertical = TextAlignVertical.center,
      this.showCursor = true,
      this.helperText,
      this.prefix,
      this.suffix,
      this.needClear = true,
      this.label,
      this.fillColor,
      this.isFloatLabel = false,
      this.floatingLabelPosition,
      this.controller,
      this.onChanged,
      this.validator,
      this.callback,
      this.widthFactor = 1.0,
      this.animationConfig = const []
      });

  @override
  State<Dateinput> createState() => _DateinputState();
}

class _DateinputState extends State<Dateinput> with TickerProviderStateMixin {

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

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
     BorderRadius borderRadius;
      if (widget.type.contains('circle')) {
      borderRadius = BorderRadius.circular(30);
    } else if (widget.type.contains('square')) {
      borderRadius = BorderRadius.zero;
    } else {
      borderRadius = BorderRadius.circular(8);
    }

     InputDecoration inputDecoration = _buildInputDecoration(borderRadius);

    return   _applyAnimations( Visibility(
        visible: true,
        child: SizedBox(
          child: Column(
                  children: [
                    if (widget.isFloatLabel)
                    Row(
                      mainAxisAlignment: widget.floatingLabelPosition ?? MainAxisAlignment.start,
                      children: [
                        if (widget.prefix != null) ...[
                          widget.prefix ?? const SizedBox(),
                          const SizedBox(width: 8),
                        ],
                        Text(widget.label ?? ''),
                        if(widget.suffix != null)...[
                          const SizedBox(width: 8),
                          widget.suffix ?? const SizedBox(),
                        ]
                      ],
                    ),
                    if (widget.isFloatLabel)
                          const SizedBox(height: 8),
                    TextFormField(
                      controller: widget.controller,
                      decoration: inputDecoration,
                      textAlign: widget.textAlign,
                      textAlignVertical: widget.textAlignVertical,
                      showCursor: widget.showCursor,
                     
                      onChanged: (value) {
                        if (widget.onChanged != null) {
                          widget.onChanged!(value);
                        }
                      
                      },
                      onTap: (){ },
                    
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
  
  InputDecoration _buildInputDecoration(BorderRadius borderRadius) {

    Color containerColor;
  switch (widget.fillColor) {
      case "primary":
        containerColor = Theme.of(context).colorScheme.primary;
        break;
      case "secondary":
        containerColor = Theme.of(context).colorScheme.secondary;
        break;
      case "tertiary":
        containerColor = Theme.of(context).colorScheme.tertiary;
        break;
      case "transparent":
        containerColor = Colors.transparent;
        break;
      case "light":
        containerColor = Colors.white;
        break;
      case "dark":
        containerColor = Colors.black;
        break;  
      case "greyShade":
        containerColor = Colors.grey.shade200;
        break;
      default:
        containerColor = Colors.transparent;
        break;
    }

        Widget isClearable = widget.needClear
    ? (widget.controller?.text.isNotEmpty ?? false)
        ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              widget.controller?.clear();
            },
          )
        : const SizedBox()
    : widget.suffix ?? const SizedBox();


     var decoration = InputDecoration(
    
      hintText: widget.hintText,
      helperText: widget.helperText,
      prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
      suffixIcon: isClearable,
      contentPadding: const EdgeInsets.symmetric(vertical: 16,horizontal: 12),
      floatingLabelBehavior: !widget.isFloatLabel
      ? FloatingLabelBehavior.auto
      : FloatingLabelBehavior.never,
    );

 switch (widget.type) {
      case 'filled-circle':
        return decoration.copyWith(
          filled: true,
          fillColor: containerColor,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: borderRadius,
          ),
        );
      case 'outlined-circle':
        return decoration.copyWith(
          filled: false,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: borderRadius,
          ),
        );
      case 'filled-square':
        return decoration.copyWith(
          filled: true,
          fillColor: containerColor,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.zero,
          ),
        );
      case 'outlined-square':
        return decoration.copyWith(
          filled: false,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: BorderRadius.zero,
          ),
        );
      case 'underlined':
        return decoration.copyWith(
          filled: false,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
        );
      default:
        return decoration.copyWith(
          filled: false,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: borderRadius,
          ),
        );
    }
  }

}


