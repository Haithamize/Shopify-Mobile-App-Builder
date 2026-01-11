import 'package:equatable/equatable.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartEnsureStarted extends CartEvent {
  const CartEnsureStarted();
}

class CartRefresh extends CartEvent {
  const CartRefresh();
}

class CartAddVariant extends CartEvent {
  const CartAddVariant({required this.variantId, required this.quantity});
  final String variantId;
  final int quantity;

  @override
  List<Object?> get props => [variantId, quantity];
}

class CartUpdateLineQty extends CartEvent {
  const CartUpdateLineQty({
    required this.lineId,
    required this.merchandiseId,
    required this.quantity,
  });

  final String lineId;
  final String merchandiseId;
  final int quantity;

  @override
  List<Object?> get props => [lineId, merchandiseId, quantity];
}

class CartRemoveLine extends CartEvent {
  const CartRemoveLine({required this.lineId});
  final String lineId;

  @override
  List<Object?> get props => [lineId];
}

class CartCheckoutRequested extends CartEvent {
  const CartCheckoutRequested();
}

class CartCheckoutCompleted extends CartEvent {
  const CartCheckoutCompleted();
}

