import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._repo) : super(CartInitial()) {
    on<CartEnsureStarted>(_onEnsure);
    on<CartRefresh>(_onRefresh);
    on<CartAddVariant>(_onAdd);
    on<CartUpdateLineQty>(_onUpdate);
    on<CartRemoveLine>(_onRemove);
    on<CartCheckoutRequested>(_onCheckout);
    on<CartCheckoutCompleted>(_onCheckoutCompleted);
  }

  final CartRepository _repo;

  Future<void> _onEnsure(CartEnsureStarted event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _repo.getOrCreateCart();
      emit(CartLoaded(cart));
    } catch (e) {
      debugPrint('❌ ensure cart failed: $e');
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRefresh(CartRefresh event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _repo.refresh();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAdd(CartAddVariant event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _repo.addVariant(
        merchandiseId: event.variantId,
        quantity: event.quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdate(CartUpdateLineQty event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _repo.updateLineQty(
        lineId: event.lineId,
        merchandiseId: event.merchandiseId,
        quantity: event.quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }


  Future<void> _onRemove(CartRemoveLine event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _repo.removeLine(lineId: event.lineId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onCheckout(CartCheckoutRequested event, Emitter<CartState> emit) async {
    // Important: don't necessarily emit CartLoading here, otherwise your cart screen will
    // flash a full loader when user taps Checkout.
    // If you WANT loading, do a separate "isCheckingOut" flag state. For now: keep it simple.

    try {
      // refresh() ensures cart still exists and gives a valid checkoutUrl
      final cart = await _repo.refresh();

      final url = cart.checkoutUrl;
      if (url == null || url.isEmpty) {
        throw Exception('Cart checkoutUrl is missing.');
      }

      // Emit a one-shot state that UI listens to
      emit(CartCheckoutReady(checkoutUrl: url, cart: cart));

      // (Optional but recommended)
      // Immediately go back to a stable state so the listener won't retrigger on rebuilds.
      emit(CartLoaded(cart));
    } catch (e) {
      debugPrint('❌ checkout failed: $e');
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onCheckoutCompleted(
      CartCheckoutCompleted event,
      Emitter<CartState> emit,
      ) async {
    emit(CartLoading());
    try {
      final newCart = await _repo.clearAfterCheckout();
      emit(CartLoaded(newCart)); // UI shows empty cart
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}


