import 'package:firebase_crud/product.dart';
import 'package:firebase_crud/product_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://cicmcyhgwxydqszhluow.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpY21jeWhnd3h5ZHFzemhsdW93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3NjQxMTgsImV4cCI6MjA1MDM0MDExOH0.edlkSFEpx13krkR6fHlnOspjUC3v4Bsr2YJQ3pz7B-Q',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPage();
}

class _ProductPage extends State<ProductPage> {
  final productsDatabase = ProductDatabase();
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final data = await Supabase.instance.client.from('product').select();
    setState(() {
      products = data.map((noteMap) => Product.fromJson(noteMap)).toList();

      print(products);
    });
  }

  Future<void> addNewProduct() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      child: Text('Create'),
                      onPressed: () async {
                        final newNote = Product(
                            name: nameController.text,
                            price: int.parse(priceController.text));

                        productsDatabase
                            .createProduct(newNote)
                            .whenComplete(() => fetchProducts());

                        nameController.clear();
                        priceController.clear();

                        Navigator.pop(context);
                      },
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  Future<void> updateProduct(Product product) async {
    nameController.text = product.name;
    priceController.text = product.price.toString();

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      child: Text('Update'),
                      onPressed: () async {
                        productsDatabase
                            .updateProduct(product, nameController.text,
                                int.parse(priceController.text))
                            .whenComplete(() => fetchProducts());

                        nameController.clear();
                        priceController.clear();

                        Navigator.pop(context);
                      },
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  Future<void> _deleteProduct(Product product) async {
    productsDatabase.deleteProduct(product).whenComplete(() => fetchProducts());

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return ListTile(
                  title: Text(product.name), //
                  subtitle: Text(
                      "${NumberFormat('###,000').format(product.price)} บาท"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => updateProduct(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addNewProduct(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
