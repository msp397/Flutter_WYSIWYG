import 'package:flutter/material.dart';

class CounterbuttonT extends StatefulWidget {
  final int? count;
  final ValueChanged<int>? onChanged;
  final String? size;
  final TextStyle? textStyle;
  final String? type;
  final Widget? prefix;
  final Widget? suffix;

  const CounterbuttonT({
    super.key, 
    this.count, 
    this.onChanged, 
    this.size, 
    this.textStyle, 
    this.type , 
    this.prefix, 
    this.suffix});

  @override
  State<CounterbuttonT> createState() => _CounterbuttonTState();
}

class _CounterbuttonTState extends State<CounterbuttonT> {

  
  void _increment() => widget.onChanged!((widget.count ?? 0) + 1);
  void _decrement() => widget.onChanged!((widget.count ?? 0) - 1);

   double _resolveSize() {
    switch (widget.size) {
      case 'small':
        return 28.0;
      case 'medium':
        return 36.0;
      case 'large':
        return 48.0;
      case 'max':
        return 60.0;
      default:
        return 36.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double resolvedSize = _resolveSize();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(widget.prefix ?? SizedBox(), _decrement, resolvedSize),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text('${widget.count ?? 0}',
            style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        ),
        _buildButton(widget.suffix ?? SizedBox(), _increment,resolvedSize),
      ],
    );
  }Widget _buildButton(Widget icon, VoidCallback onPressed, double size) {
    switch (widget.type) {
      case 'underlined':
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(size, size),
            textStyle: const TextStyle(decoration: TextDecoration.underline),
          ),
          child: icon,
        );

      default:
        bool isOutlined = widget.type == 'outlined-circle' ||
           widget.type == 'outlined-square';

        bool isFilled = widget.type == 'filled-circle' ||
            widget.type == 'filled-square';

        bool isCircle = widget.type == 'filled-circle' ||
            widget.type == 'outlined-circle';

        return SizedBox(
          width: size,
          height: size,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(size, size),
              shape: isCircle
                  ? const CircleBorder()
                  : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
              backgroundColor: isFilled ? Colors.blue : null,
              side: isOutlined
                  ? const BorderSide(color: Colors.blue)
                  : BorderSide.none,
              foregroundColor: isFilled ? Colors.white : Colors.blue,
            ),
            child: icon,
          ),
        );
    }
  }



}



