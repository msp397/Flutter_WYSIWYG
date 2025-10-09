import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

List<String> type = [
  'filled-circle',
  'outlined-circle',
  'filled-square',
  'outlined-square',
  'underlined',
];

class TTextField extends StatefulWidget {
  final String type;
  final String? hintText;
  final bool isDisabled;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final bool showCursor;
  final String? helperText;
  final Widget? prefix;
  final Widget? suffix;
  final bool needClear;
  final String? label;
  final bool isFloatLabel;
  final String? fillColor;
  final FocusNode? focusNode;
  final double widthFactor;
  final List<Map<String, dynamic>>? animationConfig;
  final MainAxisAlignment? floatingLabelPosition;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final VoidCallback? callback;

  const TTextField({
    super.key,
    this.type = 'outlined-circle',
    this.hintText,
    this.isDisabled = false,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.showCursor = true,
    this.helperText,
    this.prefix,
    this.suffix,
    this.needClear = false,
    this.controller,
    this.onChanged,
    this.validator,
    this.label,
    this.keyboardType = TextInputType.name,
    this.isFloatLabel = true,
    this.floatingLabelPosition = MainAxisAlignment.start,
    this.fillColor = 'greyShade',
    this.focusNode,
    this.widthFactor = 1.0,
    this.animationConfig = const [],
    this.callback,
  });

  @override
  State<TTextField> createState() => _TTextFieldState();
}

class _TTextFieldState extends State<TTextField> {
  final bool _isPassword = false;
  bool _isObscured = false;

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
    String? labelText = widget.isFloatLabel ? widget.label ?? 'Enter text here' : null;
    BorderRadius borderRadius;

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

    if (widget.type.contains('circle')) {
      borderRadius = BorderRadius.circular(30);
    } else if (widget.type.contains('square')) {
      borderRadius = BorderRadius.zero;
    } else {
      borderRadius = BorderRadius.circular(8);
    }

    // Determine the fill color based on fillColor
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

    InputDecoration inputDecoration;
    if (widget.type == 'filled-circle') {
        inputDecoration = InputDecoration(
          filled: true,
          fillColor: containerColor, 
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: borderRadius,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: widget.label ?? 'Enter text here',
          hintText: widget.hintText,
          helperText: widget.helperText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          floatingLabelBehavior: widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
    } else if (widget.type == 'outlined-circle'){
          inputDecoration = InputDecoration(
          filled: false,
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: borderRadius,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: widget.label ?? 'Enter text here',
          hintText: widget.hintText,
          helperText: widget.helperText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          floatingLabelBehavior: widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
    } else if (widget.type == 'filled-square') {
          inputDecoration = InputDecoration(
          filled: true,
          fillColor: containerColor,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.zero,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
          labelText: widget.label ?? 'Enter text here',
          hintText: widget.hintText,
          helperText: widget.helperText,
           prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          floatingLabelBehavior: widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
    } else if (widget.type == 'outlined-square') {
          inputDecoration = InputDecoration(
          filled: false,
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: widget.label ?? 'Enter text here',
          hintText: widget.hintText,
          helperText: widget.helperText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          floatingLabelBehavior: widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
    } else if (widget.type == 'underlined') {
       inputDecoration = InputDecoration(
          filled: false,
          border: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          labelText: widget.label ?? 'Enter text here',
          hintText: widget.hintText,
          helperText: widget.helperText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          floatingLabelBehavior: widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
    }  else {
        inputDecoration = InputDecoration(
          filled: false,
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: borderRadius,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          floatingLabelBehavior: widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
    }

    if (_isPassword) {
      inputDecoration = inputDecoration.copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      );
    } else {
      setState(() {
        _isObscured = false;
      });
    }

    void _onTap() {}

    return _applyAnimations( Visibility(
        visible: true,
        child: Column(
          children: [
            if (widget.isFloatLabel)
              Row(
                mainAxisAlignment:
                    widget.floatingLabelPosition ?? MainAxisAlignment.start,
                children: [
                  if (widget.prefix != null) widget.prefix ?? SizedBox(),
                  SizedBox(width: 8),
                  Text(widget.label ?? ''),
                  SizedBox(width: 8),
                  if (widget.suffix != null) widget.suffix ?? SizedBox(),
                ],
              ),
            SizedBox(height: 8),
        
            SizedBox(
              width: double.infinity,
              child: widget.keyboardType == TextInputType.phone
                  ? IntlPhoneField(
                      focusNode: widget.focusNode,
                      controller: widget.controller,
                      decoration: inputDecoration.copyWith(
                        labelText: widget.label ?? 'Phone Number',
                      ),
                      initialCountryCode: 'US',
                      languageCode: "en",
                      enabled: !widget.isDisabled,
                      onChanged: (phone) =>
                          widget.onChanged?.call(phone.completeNumber),
                      onCountryChanged: (country) {
                        print('Country changed to: ${country.name}');
                      },
                    )
                  : TextFormField(
                      controller: widget.controller,
                      decoration: inputDecoration,
                      keyboardType: widget.keyboardType,
                      textAlign: widget.textAlign,
                      textAlignVertical: widget.textAlignVertical,
                      showCursor: widget.showCursor,
                      obscureText: _isObscured,
                      enabled: !widget.isDisabled,
                      onChanged: widget.onChanged,
                      validator: widget.validator,
                      onTap: _onTap),
            ),
          ],
        ),
      ),
    );
  }
}
