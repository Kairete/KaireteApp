import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/account/models/account_prefs.dart';
import 'package:kairete/features/account/services/account_service.dart';
import 'package:kairete/features/account/widgets/account_form_widgets.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  final _service = AccountService();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  AccountPrefs? _prefs;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
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
      setState(() {
        _prefs = prefs;
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
    final current = _current.text;
    final next = _next.text;
    final confirm = _confirm.text;
    if (current.isEmpty || next.isEmpty) {
      AppToast.error('Compila password attuale e nuova password.');
      return;
    }
    if (next != confirm) {
      AppToast.error('La conferma password non coincide.');
      return;
    }
    if (next.length < 8) {
      AppToast.error('La nuova password deve avere almeno 8 caratteri.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.changePassword(
        currentPassword: current,
        newPassword: next,
      );
      _current.clear();
      _next.clear();
      _confirm.clear();
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.success('Password aggiornata.');
    } on AccountException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(AppToast.mapApiError(e.message));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error('Impossibile aggiornare la password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tfa = _prefs?.useTfa == true;
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Password e sicurezza'),
      ),
      body: AccountLoadBody(
        loading: _loading,
        error: _error,
        onRetry: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            AccountSectionLabel('Cambia password'),
            AccountFieldCard(
              children: [
                TextField(
                  controller: _current,
                  decoration: const InputDecoration(
                    labelText: 'Password attuale',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _next,
                  decoration: const InputDecoration(
                    labelText: 'Nuova password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirm,
                  decoration: const InputDecoration(
                    labelText: 'Conferma nuova password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Salvataggio…' : 'Aggiorna password'),
                ),
              ],
            ),
            AccountSectionLabel('Autenticazione a due fattori'),
            AccountFieldCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    tfa ? Icons.verified_user : Icons.shield_outlined,
                    color: tfa ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                  title: Text(
                    tfa ? '2FA attiva' : '2FA non attiva',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'La configurazione completa della 2FA è disponibile sul sito web.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
