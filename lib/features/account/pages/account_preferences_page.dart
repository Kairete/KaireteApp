import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/account/models/account_prefs.dart';
import 'package:kairete/features/account/services/account_service.dart';
import 'package:kairete/features/account/widgets/account_form_widgets.dart';

class AccountPreferencesPage extends StatefulWidget {
  const AccountPreferencesPage({super.key});

  @override
  State<AccountPreferencesPage> createState() => _AccountPreferencesPageState();
}

class _AccountPreferencesPageState extends State<AccountPreferencesPage> {
  final _service = AccountService();

  AccountPrefs? _prefs;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  late String _timezone;
  late String _creationWatch;
  late String _interactionWatch;
  late bool _contentShowSignature;
  late bool _emailOnConversation;
  late bool _pushOnConversation;
  late bool _receiveAdminEmail;
  late bool _showDobDate;
  late bool _showDobYear;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await _service.fetchPrefs();
      if (!mounted) return;
      _apply(prefs);
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

  void _apply(AccountPrefs prefs) {
    _timezone = AccountPrefs.timezones.contains(prefs.timezone)
        ? prefs.timezone
        : 'Europe/Rome';
    final watchIds = AccountPrefs.watchChoices.map((e) => e.$1).toSet();
    _creationWatch = watchIds.contains(prefs.creationWatchState)
        ? prefs.creationWatchState
        : 'watch_email';
    _interactionWatch = watchIds.contains(prefs.interactionWatchState)
        ? prefs.interactionWatchState
        : 'watch_email';
    _contentShowSignature = prefs.contentShowSignature;
    _emailOnConversation = prefs.emailOnConversation;
    _pushOnConversation = prefs.pushOnConversation;
    _receiveAdminEmail = prefs.receiveAdminEmail;
    _showDobDate = prefs.showDobDate;
    _showDobYear = prefs.showDobYear;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final updated = await _service.updatePrefs({
        'timezone': _timezone,
        'option[creation_watch_state]': _creationWatch,
        'option[interaction_watch_state]': _interactionWatch,
        'option[content_show_signature]': _contentShowSignature ? '1' : '0',
        'option[email_on_conversation]': _emailOnConversation ? '1' : '0',
        'option[push_on_conversation]': _pushOnConversation ? '1' : '0',
        'option[receive_admin_email]': _receiveAdminEmail ? '1' : '0',
        'option[show_dob_date]': _showDobDate ? '1' : '0',
        'option[show_dob_year]': _showDobYear ? '1' : '0',
      });
      if (!mounted) return;
      _apply(updated);
      setState(() {
        _prefs = updated;
        _saving = false;
      });
      AppToast.success('Preferenze salvate.');
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
        title: const Text('Preferenze'),
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
            AccountSectionLabel('Locale'),
            AccountFieldCard(
              children: [
                AccountDropdown<String>(
                  label: 'Fuso orario',
                  value: _timezone,
                  items: [
                    for (final tz in AccountPrefs.timezones) (tz, tz),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _timezone = v);
                  },
                ),
              ],
            ),
            AccountSectionLabel('Contenuti'),
            AccountFieldCard(
              children: [
                AccountDropdown<String>(
                  label: 'Watch automatico alla creazione',
                  value: _creationWatch,
                  items: AccountPrefs.watchChoices,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _creationWatch = v);
                  },
                ),
                const SizedBox(height: 10),
                AccountDropdown<String>(
                  label: 'Watch automatico all\'interazione',
                  value: _interactionWatch,
                  items: AccountPrefs.watchChoices,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _interactionWatch = v);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostra le firme'),
                  value: _contentShowSignature,
                  onChanged: (v) => setState(() => _contentShowSignature = v),
                ),
              ],
            ),
            AccountSectionLabel('Email e push'),
            AccountFieldCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Email per i messaggi privati'),
                  value: _emailOnConversation,
                  onChanged: (v) => setState(() => _emailOnConversation = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Push per i messaggi privati'),
                  value: _pushOnConversation,
                  onChanged: (v) => setState(() => _pushOnConversation = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Email amministrative / newsletter'),
                  value: _receiveAdminEmail,
                  onChanged: (v) => setState(() => _receiveAdminEmail = v),
                ),
              ],
            ),
            AccountSectionLabel('Data di nascita'),
            AccountFieldCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostra giorno e mese'),
                  value: _showDobDate,
                  onChanged: (v) => setState(() => _showDobDate = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostra anno'),
                  value: _showDobYear,
                  onChanged: (v) => setState(() => _showDobYear = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
