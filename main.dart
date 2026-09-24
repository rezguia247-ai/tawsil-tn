import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBase = 'http://10.0.2.2:3000/api';

void main() => runApp(const TawsilApp());

class TawsilApp extends StatelessWidget {
  const TawsilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tawsil TN',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List stores = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStores();
  }

  Future<void> loadStores() async {
    try {
      final r = await http.get(Uri.parse('$apiBase/stores'));
      setState(() {
        stores = jsonDecode(r.body);
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tawsil TN')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : stores.isEmpty
              ? const Center(child: Text('شغّل الـBackend ثم عاود جرّب'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stores.length,
                  itemBuilder: (_, i) {
                    final s = stores[i];
                    return Card(
                      child: ListTile(
                        title: Text(s['name']),
                        subtitle: Text(s['category']),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductsPage(
                              storeId: s['id'],
                              storeName: s['name'],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class ProductsPage extends StatefulWidget {
  final int storeId;
  final String storeName;
  const ProductsPage({super.key, required this.storeId, required this.storeName});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List products = [];
  final cart = <int>{};

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final r = await http.get(
      Uri.parse('$apiBase/stores/${widget.storeId}/products'),
    );
    setState(() => products = jsonDecode(r.body));
  }

  Future<void> createOrder() async {
    if (cart.isEmpty) return;
    final r = await http.post(
      Uri.parse('$apiBase/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerId': 1,
        'items': cart.map((id) => {'productId': id, 'quantity': 1}).toList(),
        'address': 'Tunis, Tunisia'
      }),
    );
    if (!mounted) return;
    final order = jsonDecode(r.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Commande #${order['id']} créée')),
    );
    setState(() => cart.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.storeName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...products.map((p) => Card(
                child: ListTile(
                  title: Text(p['name']),
                  subtitle: Text('${p['price']} DT'),
                  trailing: IconButton(
                    icon: Icon(
                      cart.contains(p['id'])
                          ? Icons.check_circle
                          : Icons.add_shopping_cart,
                    ),
                    onPressed: () => setState(() {
                      cart.contains(p['id'])
                          ? cart.remove(p['id'])
                          : cart.add(p['id']);
                    }),
                  ),
                ),
              )),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: createOrder,
            icon: const Icon(Icons.delivery_dining),
            label: Text('Commander (${cart.length})'),
          ),
        ],
      ),
    );
  }
}
