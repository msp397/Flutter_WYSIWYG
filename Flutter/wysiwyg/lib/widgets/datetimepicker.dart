import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Datetimepicker extends StatefulWidget {
  final String type;
  final String? label;
  final String? hintText;
  final bool isDisabled;
  final String? selectedDateTime;
  final void Function(String?)? onChanged;
  final String? helperText;
  final String? datetimeFormat;
  final String? fillColor;
  final bool needClear;
  final Widget? prefix;
  final Widget? suffix;
  final bool isFloatLabel;
  final MainAxisAlignment? floatingLabelPosition;
  final TextEditingController? controller;
  final VoidCallback? callback;
  final double widthFactor;
  final List<Map<String, dynamic>>? animationConfig;

  const Datetimepicker({
    super.key,
    this.type = 'outlined-circle ',
    this.label,
    this.hintText,
    this.isDisabled = false,
    this.selectedDateTime,
    this.onChanged,
    this.helperText,
    this.datetimeFormat,
    this.fillColor,
    this.needClear = true,
    this.prefix,
    this.suffix,
    this.isFloatLabel = true,
    this.floatingLabelPosition,
    this.controller,
    this.callback,
    this.widthFactor = 1.0,
    this.animationConfig = const [],
  });

  @override
  State<Datetimepicker> createState() => _DatetimepickerState();
}

class _DatetimepickerState extends State<Datetimepicker>
    with TickerProviderStateMixin {
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

  DateTime? _tryParseDateTime(String value) {
    try {
      return DateFormat(widget.datetimeFormat ?? 'yyyy-MM-dd HH:mm')
          .parseStrict(value);
    } catch (_) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
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
    switch (widget.type) {
      case 'filled-circle':
        inputDecoration = InputDecoration(
          filled: true,
          fillColor: containerColor,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: borderRadius,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: widget.label,
          hintText: widget.hintText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          helperText: widget.helperText,
          floatingLabelBehavior: !widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
        break;
      case 'outlined-circle':
        inputDecoration = InputDecoration(
          filled: false,
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: borderRadius,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: widget.label,
          hintText: widget.hintText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          helperText: widget.helperText,
          floatingLabelBehavior: !widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
        break;
      case 'filled-square':
        inputDecoration = InputDecoration(
          filled: true,
          fillColor: containerColor,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.zero,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          labelText: widget.label,
          hintText: widget.hintText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          helperText: widget.helperText,
          floatingLabelBehavior: !widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
        break;
      case 'outlined-square':
        inputDecoration = InputDecoration(
          filled: false,
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: widget.label,
          hintText: widget.hintText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          helperText: widget.helperText,
          floatingLabelBehavior: !widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
        break;
      case 'underlined':
        inputDecoration = InputDecoration(
          filled: false,
          border: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: widget.label,
          hintText: widget.hintText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          helperText: widget.helperText,
          floatingLabelBehavior: !widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
        break;
      default:
        inputDecoration = InputDecoration(
          filled: false,
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
            borderRadius: borderRadius,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelText: widget.label,
          hintText: widget.hintText,
          prefixIcon: !widget.isFloatLabel ? widget.prefix : null,
          suffixIcon: isClearable,
          helperText: widget.helperText,
          floatingLabelBehavior: !widget.isFloatLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
        );
    }

    return _applyAnimations(Visibility(
        visible: true,
        child: SizedBox(
          child: Column(
            children: [
              if (widget.isFloatLabel)
                Row(
                  mainAxisAlignment:
                      widget.floatingLabelPosition ?? MainAxisAlignment.start,
                  children: [
                    if (widget.prefix != null) ...[
                      widget.prefix ?? const SizedBox(),
                      const SizedBox(width: 8),
                    ],
                    Text(widget.label ?? ''),
                    if (widget.suffix != null) ...[
                      const SizedBox(width: 8),
                      widget.suffix ?? const SizedBox(),
                    ]
                  ],
                ),
              if (widget.isFloatLabel) const SizedBox(height: 8),
              TextFormField(
                controller: widget.controller,
                decoration: inputDecoration,
                readOnly: true,
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                },
              ),
            ],
          ),
        )));
  }

  // SHOW DATETIME PICKER
  Future<void> _selectDateAndTime() async {
    DateTime initialDate = widget.selectedDateTime != null &&
            _tryParseDateTime(widget.selectedDateTime!) != null
        ? _tryParseDateTime(widget.selectedDateTime!)!
        : DateTime.now();

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (selectedTime != null) {
        DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        String formatted = _formatDateTime(combinedDateTime);

        setState(() {
          widget.controller!.text = formatted;
        });

        widget.onChanged?.call(formatted); // ✅ always return String
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    String format = widget.datetimeFormat ?? 'yyyy-MM-dd HH:mm a';
    return DateFormat(format).format(dateTime);
  }
}
