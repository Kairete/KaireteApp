import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: LoginProbe(), debugShowCheckedModeBanner: false));
}
class LoginProbe extends StatefulWidget {
  const LoginProbe({super.key});
  @override
  State<LoginProbe> createState() => _LoginProbeState();
}
class _LoginProbeState extends State<LoginProbe> {
  final host = TextEditingController(text: 'https://www.kairete.it/');
  final key = TextEditingController();
  final login = TextEditingController();
  final password = TextEditingController();
  String info = 'Test isolato: login, verifica sessione e logout.';
  bool busy = false, active = false;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    host.text = await storage.read(key: 'kt_host') ?? host.text;
    key.text = await storage.read(key: 'kt_guest_key') ?? '';
    if (mounted) setState(() {});
    if (key.text.isNotEmpty) await verify();
  }
  @override
  void dispose() {
    host.dispose(); key.dispose(); login.dispose(); password.dispose();
    super.dispose();
  }
  Future<String> device() async {
    var v = await storage.read(key: 'kt_device');
    if (v != null && v.isNotEmpty) return v;
    final r = Random.secure();
    v = List.generate(32, (_) => r.nextInt(256).toRadixString(16).padLeft(2,'0')).join();
    await storage.write(key: 'kt_device', value: v);
    return v;
  }
  Future<Map<String,dynamic>> post(String route, Map<String,String> data) async {
    final url = host.text.trim();
    final api = key.text.trim();
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
      throw StateError('Inserisci un indirizzo HTTPS valido.');
    }
    if (api.isEmpty) throw StateError('Serve una chiave guest limitata per il test.');
    await storage.write(key:'kt_host',value:url);
    await storage.write(key:'kt_guest_key',value:api);
    final dio = Dio(BaseOptions(
      baseUrl: url.endsWith('/') ? url : url + '/',
      headers: {'Accept':'application/json','XF-Api-Key':api},
      connectTimeout: const Duration(seconds:20),
      receiveTimeout: const Duration(seconds:20),
      validateStatus: (s) => s != null && s < 500,
    ));
    try {
      final response = await dio.post<dynamic>('api/' + route, data: FormData.fromMap(data));
      if (response.data is! Map) throw StateError('Risposta API non JSON.');
      final result = Map<String,dynamic>.from(response.data as Map);
      if (result['errors'] is List && (result['errors'] as List).isNotEmpty) {
        final e = (result['errors'] as List).first;
        throw StateError(e is Map ? (e['message'] ?? 'Errore API').toString() : e.toString());
      }
      if ((response.statusCode ?? 500) >= 400) throw StateError('Errore HTTP ' + response.statusCode.toString());
      return result;
    } finally { dio.close(); }
  }
  Future<void> perform(Future<void> Function() fn) async {
    if (busy) return;
    setState(() { busy = true; info = 'Connessione…'; });
    try { await fn(); }
    catch (e) { if (mounted) setState(() => info = e.toString().replaceFirst('Bad state: ','')); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> signIn() => perform(() async {
    if (login.text.trim().isEmpty || password.text.isEmpty) throw StateError('Inserisci username e password.');
    final result = await post('ms-auth-login', {
      'login':login.text.trim(), 'password':password.text,
      'device_key':await device(), 'app_id':'kairete',
    });
    final token = (result['session_token'] ?? '').toString();
    final user = result['user'];
    if (token.isEmpty || user is! Map || (int.tryParse(user['user_id'].toString()) ?? 0) <= 0) {
      throw StateError('La risposta di login non contiene un utente valido.');
    }
    await storage.write(key:'kt_token',value:token);
    password.clear();
    if (mounted) setState(() {active=true;info='Login riuscito: ' + user['username'].toString();});
  });
  Future<void> verify() => perform(() async {
    final token=await storage.read(key:'kt_token');
    if (token == null || token.isEmpty) {
      if (mounted) setState(() {active=false;info='Nessuna sessione salvata.';});
      return;
    }
    try {
      final result=await post('ms-auth-verify', {
        'session_token':token,'device_key':await device(),'app_id':'kairete',
      });
      if ((int.tryParse((result['user_id'] ?? '').toString()) ?? 0) <= 0) {
        throw StateError('Sessione non valida.');
      }
      if (mounted) setState(() {active=true;info='Sessione verificata sul server.';});
    } catch (_) {await storage.delete(key:'kt_token');rethrow;}
  });
  Future<void> signOut() => perform(() async {
    final token=await storage.read(key:'kt_token');
    if (token != null && token.isNotEmpty) {
      await post('ms-auth-logout', {
        'session_token':token,'device_key':await device(),'app_id':'kairete',
      });
    }
    await storage.delete(key:'kt_token');
    if (mounted) setState(() {active=false;info='Sessione revocata. Logout completato.';});
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:AppBar(title:const Text('Kairete — Login TEST')),
    body:Center(child:ConstrainedBox(
      constraints:const BoxConstraints(maxWidth:450),
      child:ListView(padding:const EdgeInsets.all(24),children:[
        const Text('SOLO COLLAUDO · Non distribuire',style:TextStyle(fontWeight:FontWeight.bold)),
        TextField(controller:host,decoration:const InputDecoration(labelText:'Server staging HTTPS')),
        TextField(controller:key,obscureText:true,decoration:const InputDecoration(labelText:'Chiave guest limitata')),
        const SizedBox(height:16),
        if (!active) ...[
          TextField(controller:login,decoration:const InputDecoration(labelText:'Username o email')),
          TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Password')),
          FilledButton(onPressed:busy?null:signIn,child:const Text('Accedi')),
          OutlinedButton(onPressed:busy?null:verify,child:const Text('Ripristina sessione')),
        ] else ...[
          FilledButton(onPressed:busy?null:verify,child:const Text('Verifica sessione')),
          OutlinedButton(onPressed:busy?null:signOut,child:const Text('Logout')),
        ],
        if(busy) const LinearProgressIndicator(),
        const SizedBox(height:12),
        SelectableText(info),
        const SizedBox(height:20),
        const Text('Usa solo un account non amministrativo di prova, senza 2FA. La chiave guest resta sul telefono: non usare chiavi privilegiate.'),
      ]),
    )),
  );
}
