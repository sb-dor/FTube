import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_event.dart';

class CreatePlayListPopup extends StatefulWidget {
  const CreatePlayListPopup({super.key});

  @override
  State<CreatePlayListPopup> createState() => _CreatePlayListPopupState();
}

class _CreatePlayListPopupState extends State<CreatePlayListPopup> {
  final TextEditingController _textEditingController = TextEditingController(text: '');
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  bool valueIsEmpty = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New playlist"),
      content: Form(
        key: _formState,
        child: TextFormField(
          controller: _textEditingController,
          onChanged: (value) {
            if (value.isEmpty && !valueIsEmpty) valueIsEmpty = true;
            if (value.isNotEmpty && valueIsEmpty) valueIsEmpty = false;
            setState(() {});
          },
          validator: (value) {
            if ((value ?? '').isEmpty) return "Field can't be empty";
            return null;
          },
          maxLength: 25,
          decoration: const InputDecoration(
            hintText: "Name of the playlist",
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (!_formState.currentState!.validate()) return;
            context
                .read<PlaylistsBloc>()
                .add(CreatePlaylistEvent(name: _textEditingController.text.trim()));
            Navigator.pop(context);
          },
          child: Text(
            "Create",
            style: TextStyle(
              color: valueIsEmpty ? Colors.red.shade200 : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
