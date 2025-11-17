import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;

  Map<String, dynamic> toOrderItem() {
    return {
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'qty': quantity,
    };
  }
}

