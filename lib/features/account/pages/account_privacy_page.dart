import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/account/models/account_prefs.dart';
import 'package:kairete/features/account/services/account_service.dart';
import 'package:kairete/features/account/widgets/account_form_widgets.dart';

class AccountPrivacyPage extends StatefulWidget {
  const AccountPrivacyPage({super.key});

  @override
  State<AccountPrivacyPage> createState() => _AccountPrivacyPageState();
}

class _AccountPrivacyPageState extends State<AccountPrivacyPage> {
  final _service = AccountService();

  AccountPrefs? _prefs;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  late bool _visible;
  late bool _activityVisible;
  late String _allowViewProfile;
  late String _allowPostProfile;
  late String _allowReceiveNewsFeed;
  late String _allowSendPersonalConversation;
  late String _allowViewIdentities;

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
    _visible = prefs.visible;
    _activityVisible = prefs.activityVisible;
    _allowViewProfile = prefs.allowViewProfile;
    _allowPostProfile = prefs.allowPostProfile;
    _allowReceiveNewsFeed = prefs.allowReceiveNewsFeed;
    _allowSendPersonalConversation = prefs.allowSendPersonalConversation;
    _allowViewIdentities = prefs.allowViewIdentities;
  }

  String _safePrivacy(String value) {
    final allowed = AccountPrefs.privacyChoices.map((e) => e.$1).toSet();
    return allowed.contains(value) ? value : 'members';
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final updated = await _service.updatePrefs({
        'visible': _visible ? '1' : '0',
        'activity_visible': _activityVisible ? '1' : '0',
        'privacy[allow_view_profile]': _allowViewProfile,
        'privacy[allow_post_profile]': _allowPostProfile,
        'privacy[allow_receive_news_feed]': _allowReceiveNewsFeed,
        'privacy[allow_send_personal_conversation]':
            _allowSendPersonalConversation,
        'privacy[allow_view_identities]': _allowViewIdentities,
      });
      if (!mounted) return;
      _apply(updated);
      setState(() {
        _prefs = updated;
        _saving = false;
      });
      AppToast.success('Privacy salvata.');
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
        title: const Text('Privacy'),
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
            AccountSectionLabel('Stato'),
            AccountFieldCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostra come online'),
                  value: _visible,
                  onChanged: (v) => setState(() => _visible = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mostra attività corrente'),
                  value: _activityVisible,
                  onChanged: (v) => setState(() => _activityVisible = v),
                ),
              ],
            ),
            AccountSectionLabel('Chi può…'),
            AccountFieldCard(
              children: [
                AccountDropdown<String>(
                  label: 'Vedere il tuo profilo',
                  value: _safePrivacy(_allowViewProfile),
                  items: AccountPrefs.privacyChoices,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _allowViewProfile = v);
                  },
                ),
                const SizedBox(height: 10),
                AccountDropdown<String>(
                  label: 'Pubblicare sul tuo profilo',
                  value: _safePrivacy(_allowPostProfile),
                  items: AccountPrefs.privacyChoices,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _allowPostProfile = v);
                  },
                ),
                const SizedBox(height: 10),
                AccountDropdown<String>(
                  label: 'Ricevere il tuo news feed',
                  value: _safePrivacy(_allowReceiveNewsFeed),
                  items: AccountPrefs.privacyChoices,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _allowReceiveNewsFeed = v);
                  },
                ),
                const SizedBox(height: 10),
                AccountDropdown<String>(
                  label: 'Inviarti messaggi privati',
                  value: _safePrivacy(_allowSendPersonalConversation),
                  items: AccountPrefs.privacyChoices,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _allowSendPersonalConversation = v);
                  },
                ),
                const SizedBox(height: 10),
                AccountDropdown<String>(
                  label: 'Vedere le tue identità',
                  value: _safePrivacy(_allowViewIdentities),
                  items: AccountPrefs.privacyChoices,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _allowViewIdentities = v);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
