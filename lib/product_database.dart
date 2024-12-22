import 'package:firebase_crud/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDatabase {
  final database = Supabase.instance.client.from('product');

  Future createProduct(Product newNote) async {
    await database.insert(newNote.toMap());
  }

  Future updateProduct(Product oldProduct, String name, int price) async {
    await database
        .update({'name': name, 'price': price}).eq('id', oldProduct.id!);
  }

  Future deleteProduct(Product product) async {
    await database.delete().eq('id', product.id!);
  }
}
