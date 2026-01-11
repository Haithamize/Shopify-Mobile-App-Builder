import 'package:equatable/equatable.dart';
import 'package:shopify_flutter/shopify_flutter.dart' as sf;

sealed class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}
class CartLoading extends CartState {}

class CartLoaded extends CartState {
  const CartLoaded(this.cart);
  final sf.Cart cart;

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  const CartError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class CartCheckoutReady extends CartState {
  const CartCheckoutReady({
    required this.checkoutUrl,
    required this.cart,
  });

  final String checkoutUrl;
  final sf.Cart cart;

  @override
  List<Object?> get props => [checkoutUrl, cart];
}

