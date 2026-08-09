import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/account/models/account_prefs.dart';
import 'package:kairete/features/account/services/account_service.dart';
import 'package:kairete/features/account/widgets/account_form_widgets.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final _service = AccountService();
  final _location = TextEditingController();
  final _website = TextEditingController();
  final _about = TextEditingController();
  final _customTitle = TextEditingController();
  final _email = TextEditingController();
  final _emailPassword = TextEditingController();

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
    _location.dispose();
    _website.dispose();
    _about.dispose();
    _customTitle.dispose();
    _email.dispose();
    _emailPassword.dispose();
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
      _location.text = prefs.location;
      _website.text = prefs.website;
      _about.text = prefs.about;
      _customTitle.text = prefs.customTitle;
      _email.text = prefs.email;
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

  Future<void> _saveProfile() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _service.updatePrefs({
        'profile[location]': _location.text.trim(),
        'profile[website]': _website.text.trim(),
        'profile[about]': _about.text.trim(),
        'custom_title': _customTitle.text.trim(),
      });
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.success('Dettagli salvati.');
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

  Future<void> _saveEmail() async {
    if (_saving) return;
    final email = _email.text.trim();
    final pwd = _emailPassword.text;
    if (email.isEmpty || pwd.isEmpty) {
      AppToast.error('Inserisci email e password attuale.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.changeEmail(email: email, currentPassword: pwd);
      _emailPassword.clear();
      await _load();
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.success('Email aggiornata.');
    } on AccountException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(AppToast.mapApiError(e.message));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error('Impossibile aggiornare l\'email.');
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
        title: const Text('Dettagli account'),
        actions: [
          if (_prefs != null)
            TextButton(
              onPressed: _saving ? null : _saveProfile,
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
            AccountSectionLabel('Profilo'),
            AccountFieldCard(
              children: [
                Text(
                  'Utente: ${_prefs?.username ?? ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customTitle,
                  decoration: const InputDecoration(
                    labelText: 'Titolo personalizzato',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _location,
                  decoration: const InputDecoration(labelText: 'Località'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _website,
                  decoration: const InputDecoration(labelText: 'Sito web'),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _about,
                  decoration: const InputDecoration(labelText: 'Informazioni'),
                  maxLines: 4,
                ),
              ],
            ),
            AccountSectionLabel('Email'),
            AccountFieldCard(
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailPassword,
                  decoration: const InputDecoration(
                    labelText: 'Password attuale',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _saveEmail,
                  child: const Text('Aggiorna email'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
