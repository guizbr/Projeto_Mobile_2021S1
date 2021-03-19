import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage);

  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();

  bool _isComponsing = false;
  File _image;

  void _reset(){
    _controller.clear();
    setState(() {
      _isComponsing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.photo_camera), onPressed: () async {
            // ignore: invalid_use_of_visible_for_testing_member
            final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
            if(pickedFile == null) return;
            setState(() {
              _image = File(pickedFile.path);
            });
            widget.sendMessage(imgFile: _image);
          }),
          Expanded(child: TextField(
            controller: _controller,
            decoration: InputDecoration.collapsed(hintText: "Enviar uma Mensagem"),
            onChanged: (text){
              setState(() {
                _isComponsing = text.isNotEmpty;
              });
            },
            onSubmitted: (text){
              widget.sendMessage(text: text);
              _reset();
            },
          )),
          IconButton(icon: Icon(Icons.send), onPressed: _isComponsing ? (){
            widget.sendMessage(text: _controller.text);
            _reset();
          } : null),
        ],
      ),
    );
  }
}
