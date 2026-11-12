import 'package:flutter/material.dart';

void main() => runApp(const MandiriDemoApp());

const navy = Color(0xFF063B78);
const blue = Color(0xFF0875C9);
const yellow = Color(0xFFFFD429);
const bg = Color(0xFFF4F6FA);
const ink = Color(0xFF182536);
const muted = Color(0xFF7B8794);

class MandiriDemoApp extends StatelessWidget {
  const MandiriDemoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Mandiri Mobile Demo',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: navy),
      appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: ink, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    ),
    home: const AuthGate(),
  );
}

class DemoUser {
  String name;
  String email;
  String password;
  double balance;
  DemoUser(this.name, this.email, this.password, {this.balance = 12850000});
}

class Tx {
  final String title, date, detail;
  final double amount;
  final bool incoming;
  Tx(this.title, this.date, this.detail, this.amount, this.incoming);
}

class DemoStore extends ChangeNotifier {
  DemoUser? user;
  final Map<String, DemoUser> _users = {
    'demo@mandiri.test': DemoUser('Achmad Arif', 'demo@mandiri.test', '123456'),
  };
  final List<Tx> transactions = [
    Tx('Belanja Mart', '10 Nov 2026 • 10:24', 'Pembayaran merchant', 185000, false),
    Tx('Top Up E-Wallet', '09 Nov 2026 • 18:12', 'Top up dompet digital', 100000, false),
    Tx('Transfer masuk', '08 Nov 2026 • 09:40', 'Dari rekening keluarga', 2500000, true),
  ];

  bool login(String email, String password) {
    final found = _users[email.trim().toLowerCase()];
    if (found == null || found.password != password) return false;
    user = found; notifyListeners(); return true;
  }
  bool register(String name, String email, String password) {
    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) return false;
    final newUser = DemoUser(name.trim(), key, password, balance: 5000000);
    _users[key] = newUser; user = newUser; notifyListeners(); return true;
  }
  void logout() { user = null; notifyListeners(); }
  bool transfer(String recipient, String account, double amount) {
    if (user == null || amount <= 0 || amount > user!.balance) return false;
    user!.balance -= amount;
    transactions.insert(0, Tx('Transfer ke $recipient', 'Baru saja', 'Rekening •••• ${account.length > 4 ? account.substring(account.length - 4) : account}', amount, false));
    notifyListeners(); return true;
  }
  void payQris(double amount, String merchant) {
    if (user == null || amount <= 0 || amount > user!.balance) return;
    user!.balance -= amount;
    transactions.insert(0, Tx('QRIS $merchant', 'Baru saja', 'Pembayaran QRIS simulasi', amount, false));
    notifyListeners();
  }
}

final store = DemoStore();

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (_, __) => store.user == null ? const LoginPage() : const MainShell(),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(text: 'demo@mandiri.test');
  final password = TextEditingController(text: '123456');
  bool hide = true;
  String? error;
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  void submit() {
    if (!store.login(email.text, password.text)) setState(() => error = 'Email atau password tidak sesuai.');
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const BrandMark(),
          const SizedBox(height: 28),
          const Text('Selamat datang', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 7),
          const Text('Masuk ke prototype Mandiri Mobile', style: TextStyle(color: muted)),
          const SizedBox(height: 28),
          const FieldLabel('Email'),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'nama@email.com', prefixIcon: Icon(Icons.mail_outline))),
          const SizedBox(height: 16),
          const FieldLabel('Password'),
          TextField(controller: password, obscureText: hide, decoration: InputDecoration(hintText: 'Masukkan password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => hide = !hide), icon: Icon(hide ? Icons.visibility : Icons.visibility_off)))),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 22),
          FilledButton(onPressed: submit, style: primaryButton, child: const Text('Masuk')),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())), child: const Text('Belum punya akun? Daftar')),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFE8F1FC), borderRadius: BorderRadius.circular(14)), child: const Text('Akun demo untuk mencoba:\\nEmail: demo@mandiri.test\\nPassword: 123456', style: TextStyle(fontSize: 12, height: 1.6, color: navy))),
          const SizedBox(height: 18),
          const Text('Prototype edukasi. Bukan aplikasi resmi Bank Mandiri dan tidak terhubung ke rekening atau layanan perbankan.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 11, height: 1.5)),
        ],
      )),
    ))),
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController(), email = TextEditingController(), pass = TextEditingController();
  String? error;
  @override
  void dispose() { name.dispose(); email.dispose(); pass.dispose(); super.dispose(); }
  void register() {
    if (name.text.trim().isEmpty || !email.text.contains('@') || pass.text.length < 6) {
      setState(() => error = 'Isi nama, email valid, dan password minimal 6 karakter.'); return;
    }
    if (!store.register(name.text, email.text, pass.text)) { setState(() => error = 'Email sudah terdaftar.'); return; }
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Buat akun demo')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const Text('Registrasi', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8), const Text('Buat akun lokal untuk mencoba aplikasi.', style: TextStyle(color: muted)),
      const SizedBox(height: 24), const FieldLabel('Nama lengkap'), TextField(controller: name, decoration: const InputDecoration(hintText: 'Nama Anda')),
      const SizedBox(height: 15), const FieldLabel('Email'), TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'nama@email.com')),
      const SizedBox(height: 15), const FieldLabel('Password'), TextField(controller: pass, obscureText: true, decoration: const InputDecoration(hintText: 'Minimal 6 karakter')),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 24), FilledButton(onPressed: register, style: primaryButton, child: const Text('Daftar')),
      const SizedBox(height: 12), const Text('Data registrasi hanya tersimpan sementara di memori aplikasi demo.', style: TextStyle(color: muted, fontSize: 11)),
    ]),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [HomePage(), ActivityPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: index, children: pages)),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Aktivitas'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
      ],
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  bool showBalance = true;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (_, __) => CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 18), child: Row(children: [
        const BrandMark(size: 42), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Selamat datang,', style: TextStyle(color: muted, fontSize: 12)), Text(store.user?.name ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))])),
        IconButton(onPressed: () => snack(context, 'Tidak ada notifikasi baru.'), icon: const Icon(Icons.notifications_none_rounded, color: navy)),
      ]))),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF052E63), Color(0xFF0879C9)]), borderRadius: BorderRadius.circular(23), boxShadow: [BoxShadow(color: navy.withOpacity(.17), blurRadius: 20, offset: const Offset(0, 9))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18), const SizedBox(width: 8), const Text('Total Saldo', style: TextStyle(color: Colors.white70)), const Spacer(), IconButton(onPressed: () => setState(() => showBalance = !showBalance), icon: Icon(showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white))]),
          Text(showBalance ? rupiah(store.user!.balance) : 'Rp ••••••••', style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18), Container(height: 1, color: Colors.white24), const SizedBox(height: 13),
          const Row(children: [Text('MANDIRI TABUNGAN', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)), Spacer(), Text('••••  ••••  2841', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
        ]),
      ))),
      SliverToBoxAdapter(child: sectionTitle('Transaksi utama')),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        actionTile(context, Icons.swap_horiz_rounded, 'Transfer', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferPage()))),
        actionTile(context, Icons.qr_code_2_rounded, 'QRIS', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrisPage()))),
        actionTile(context, Icons.phone_android_rounded, 'Top Up', () => snack(context, 'Menu Top Up merupakan simulasi.')),
        actionTile(context, Icons.receipt_long_rounded, 'Bayar', () => snack(context, 'Menu pembayaran merupakan simulasi.')),
      ]))),
      SliverToBoxAdapter(child: sectionTitle('Layanan')),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(padding: const EdgeInsets.symmetric(vertical: 18), decoration: whiteCard, child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ServiceIcon(Icons.flash_on, 'PLN'), ServiceIcon(Icons.water_drop, 'Air'), ServiceIcon(Icons.wifi, 'Internet'), ServiceIcon(Icons.credit_card, 'Kartu'), ServiceIcon(Icons.more_horiz, 'Lainnya'),
      ])))),

SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3C4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.celebration,
            color: navy,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promo spesial untuk Anda',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Temukan penawaran menarik di sini.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6F6240),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),

      SliverToBoxAdapter(child: sectionTitle('Transaksi terakhir', trailing: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityPage())), child: const Text('Lihat semua')))),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: TransactionList(items: store.transactions.take(3).toList()))),
    ]),
  );
}

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});
  @override
  State<TransferPage> createState() => _TransferPageState();
}
class _TransferPageState extends State<TransferPage> {
  final recipient = TextEditingController(), account = TextEditingController(), amount = TextEditingController();
  @override
  void dispose() { recipient.dispose(); account.dispose(); amount.dispose(); super.dispose(); }
  void submit() {
    final value = double.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '.'));
    if (recipient.text.trim().isEmpty || account.text.trim().length < 6 || value == null || value <= 0) { snack(context, 'Periksa nama, nomor rekening, dan nominal.'); return; }
    if (!store.transfer(recipient.text.trim(), account.text.trim(), value)) { snack(context, 'Saldo tidak cukup atau nominal tidak valid.'); return; }
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Transfer berhasil (simulasi)'), content: Text('Transfer ${rupiah(value)} ke ${recipient.text} berhasil dicatat pada riwayat demo.'), actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Selesai'))]));
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Transfer')), body: ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Transfer antar rekening', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('Simulasi transaksi — tidak mengirim uang sungguhan.', style: TextStyle(color: muted)),
    const SizedBox(height: 24), const FieldLabel('Nama penerima'), TextField(controller: recipient, decoration: const InputDecoration(hintText: 'Nama penerima')),
    const SizedBox(height: 16), const FieldLabel('Nomor rekening tujuan'), TextField(controller: account, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Masukkan nomor rekening')),
    const SizedBox(height: 16), const FieldLabel('Nominal transfer (Rp)'), TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Contoh: 100000')),
    const SizedBox(height: 28), FilledButton(onPressed: submit, style: primaryButton, child: const Text('Konfirmasi transfer')),
  ]));
}

class QrisPage extends StatefulWidget {
  const QrisPage({super.key});
  @override
  State<QrisPage> createState() => _QrisPageState();
}
class _QrisPageState extends State<QrisPage> {
  final amount = TextEditingController(text: '25000');
  final merchant = TextEditingController(text: 'Kedai Demo');
  @override
  void dispose() { amount.dispose(); merchant.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('QRIS')), body: ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Pembayaran QRIS', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), const Text('Contoh alur pembayaran tanpa pemindaian QR sungguhan.', style: TextStyle(color: muted)),
    const SizedBox(height: 24), Container(padding: const EdgeInsets.all(25), decoration: whiteCard, child: const Column(children: [Icon(Icons.qr_code_2_rounded, size: 150, color: navy), SizedBox(height: 8), Text('QRIS DEMO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)), Text('Kode contoh, bukan kode pembayaran aktif.', style: TextStyle(color: muted, fontSize: 11))])),
    const SizedBox(height: 22), const FieldLabel('Nama merchant'), TextField(controller: merchant, decoration: const InputDecoration()),
    const SizedBox(height: 14), const FieldLabel('Nominal (Rp)'), TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration()),
    const SizedBox(height: 22), FilledButton(onPressed: () {
      final value = double.tryParse(amount.text);
      if (value == null || value <= 0 || value > store.user!.balance) { snack(context, 'Nominal tidak valid atau saldo tidak cukup.'); return; }
      store.payQris(value, merchant.text.trim().isEmpty ? 'Merchant Demo' : merchant.text.trim());
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Pembayaran berhasil (simulasi)'), content: Text('${rupiah(value)} dicatat pada riwayat demo.'), actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Selesai'))]));
    }, style: primaryButton, child: const Text('Bayar sekarang')),
  ]));
}

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: store, builder: (_, __) => Scaffold(
    appBar: AppBar(title: const Text('Aktivitas transaksi')),
    body: store.transactions.isEmpty ? const Center(child: Text('Belum ada transaksi.')) : ListView(padding: const EdgeInsets.all(20), children: [const Text('Riwayat Anda', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)), const SizedBox(height: 18), TransactionList(items: store.transactions)]),
  ));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: store, builder: (_, __) => Scaffold(
    appBar: AppBar(title: const Text('Profil')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const CircleAvatar(radius: 38, backgroundColor: Color(0xFFE5F0FB), child: Icon(Icons.person, size: 42, color: navy)),
      const SizedBox(height: 13), Center(child: Text(store.user!.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20))), Center(child: Text(store.user!.email, style: const TextStyle(color: muted))),
      const SizedBox(height: 25), const ProfileItem(Icons.person_outline, 'Informasi akun'), const ProfileItem(Icons.security_outlined, 'Keamanan'), const ProfileItem(Icons.help_outline, 'Pusat bantuan'),
      const SizedBox(height: 18), OutlinedButton.icon(onPressed: store.logout, icon: const Icon(Icons.logout), label: const Text('Keluar')),
      const SizedBox(height: 18), const Text('Prototype edukasi. Tidak terhubung ke layanan resmi Bank Mandiri.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 11)),
    ]),
  ));
}

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 48});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(size * .28)), child: Center(child: Text('M', style: TextStyle(color: yellow, fontWeight: FontWeight.w900, fontSize: size * .62))));
}
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)));
}
class ServiceIcon extends StatelessWidget {
  final IconData icon; final String label;
  const ServiceIcon(this.icon, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, color: blue, size: 22), const SizedBox(height: 7), Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))]);
}
class ProfileItem extends StatelessWidget {
  final IconData icon; final String title;
  const ProfileItem(this.icon, this.title, {super.key});
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: navy), title: Text(title), trailing: const Icon(Icons.chevron_right));
}
class TransactionList extends StatelessWidget {
  final List<Tx> items;
  const TransactionList({required this.items, super.key});
  @override
  Widget build(BuildContext context) => Container(decoration: whiteCard, padding: const EdgeInsets.symmetric(horizontal: 15), child: Column(children: items.asMap().entries.map((e) {
    final t = e.value;
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFEEF4FB), borderRadius: BorderRadius.circular(13)), child: Icon(t.incoming ? Icons.call_received : Icons.call_made, color: navy)),
        const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(height: 4), Text(t.detail, style: const TextStyle(color: muted, fontSize: 10)), Text(t.date, style: const TextStyle(color: muted, fontSize: 10))])),
        Text('${t.incoming ? '+' : '-'} ${rupiah(t.amount)}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: t.incoming ? Colors.green : ink)),
      ])),
      if (e.key != items.length - 1) const Divider(height: 1),
    ]);
  }).toList()));
}
Widget sectionTitle(String title, {Widget? trailing}) => Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 13), child: Row(children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const Spacer(), if (trailing != null) trailing]));
Widget actionTile(BuildContext context, IconData icon, String label, VoidCallback onTap) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 2), decoration: whiteCard, child: Column(children: [Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: navy)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))])))));
void snack(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
String rupiah(double n) => 'Rp ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
const whiteCard = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(18)));
final primaryButton = FilledButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)));
