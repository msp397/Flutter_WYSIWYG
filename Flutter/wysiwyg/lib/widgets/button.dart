import 'package:flutter/material.dart';

class TorusButton extends StatefulWidget {
  final String? text;
  final String? varient;
  
  const TorusButton({
    super.key,
    this.text, 
    this.varient,
  });

  @override
  State<TorusButton> createState() => _TorusButtonState();
}

class _TorusButtonState extends State<TorusButton> {
  @override
  Widget build(BuildContext context) {
    if(widget.varient == 'primary') {
      return ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.black),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
        child: Text(widget.text ?? 'Click Me'),
      ); 
    } else if(widget.varient == 'secondary') {
       return ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.yellow),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        child: Text(widget.text ?? 'Click Me'),
      ); 
    } else if(widget.varient == 'tertiary') {
       return ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.orange),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        child: Text(widget.text ?? 'Click Me'),
      ); 
    } else if(widget.varient == 'success') {
       return ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        child: Text(widget.text ?? 'Click Me'),
      );  
    } else if(widget.varient == 'error') {
       return ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        child: Text(widget.text ?? 'Click Me'),
      );  
    } else if(widget.varient == 'info') {
       return ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
        child: Text(widget.text ?? 'Click Me'),
      );  
    } else if(widget.varient == 'warning') {
       return ElevatedButton(
        onPressed: () {}, 
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        child: Text(widget.text ?? 'Click Me'),
      );  
    }
    return ElevatedButton(onPressed: () {}, child: Text(widget.text ?? 'Click Me'));
  }
}
