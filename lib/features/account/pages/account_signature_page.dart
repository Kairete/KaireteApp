import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/account/models/account_prefs.dart';
import 'package:kairete/features/account/services/account_service.dart';
import 'package:kairete/features/account/widgets/account_form_widgets.dart';

class AccountSignaturePage extends StatefulWidget {
  const AccountSignaturePage({super.key});

  @override
  State<AccountSignaturePage> createState() => _AccountSignaturePageState();
}

class _AccountSignaturePageState extends State<AccountSignaturePage> {
  final _service = AccountService();
  final _signature = TextEditingController();

  AccountPrefs? _prefs;
  bool _loading = true;
  bool _saving = false;
  bool _showSignature = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _signature.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await _service.fetchPrefs();
      if (!mounted) return;
      _signature.text = prefs.signature;
      setState(() {
        _prefs = prefs;
        _showSignature = prefs.contentShowSignature;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final updated = await _service.updatePrefs({
        'profile[signature]': _signature.text,
        'option[content_show_signature]': _showSignature ? '1' : '0',
      });
      if (!mounted) return;
      _signature.text = updated.signature;
      setState(() {
        _prefs = updated;
        _showSignature = updated.contentShowSignature;
        _saving = false;
      });
      AppToast.success('Firma salvata.');
    } on AccountException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(AppToast.mapApiError(e.message));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error('Impossibile salvare.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Firma'),
        actions: [
          if (_prefs != null)
            TextButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving ? '…' : 'Salva',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: AccountLoadBody(
        loading: _loading,
        error: _error,
        onRetry: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            AccountSectionLabel('La tua firma'),
            AccountFieldCard(
              children: [
                TextField(
                  controller: _signature,
                  decoration: const InputDecoration(
                    labelText: 'Firma',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  minLines: 5,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostra le firme nei contenuti'),
                  value: _showSignature,
                  onChanged: (v) => setState(() => _showSignature = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
