import 'package:flutter/material.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/groups/services/groups_service.dart';

class GroupComposePage extends StatefulWidget {
  const GroupComposePage({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupComposePage> createState() => _GroupComposePageState();
}

class _GroupComposePageState extends State<GroupComposePage> {
  final _ctrl = TextEditingController();
  final _service = GroupsService();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await _service.createPost(groupId: widget.groupId, message: text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on GroupsException catch (e) {
      AppToast.error(e.message);
    } catch (_) {
      AppToast.error('Impossibile pubblicare il post.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _ctrl.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo post'),
        actions: [
          TextButton(
            onPressed: canSend && !_sending ? _publish : null,
            child: Text(_sending ? '...' : 'Pubblica'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _ctrl,
          autofocus: true,
          maxLines: 12,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Scrivi qualcosa…',
            alignLabelWithHint: true,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
