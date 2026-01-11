import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopiney/features/catalogue/bloc/product/products_event.dart';
import '../../domain/repositories/products_repository.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this._repo) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoad);
  }

  final ProductsRepository _repo;

  Future<void> _onLoad(LoadProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    try {
      final items = await _repo.getProducts(
        limit: event.limit,
        forceRefresh: event.forceRefresh,
      );
      emit(ProductsLoaded(items));
    } catch (e) {
      debugPrint('❌ ProductsBloc LoadProducts failed: $e');
      emit(ProductsError(e.toString()));
    }
  }
}
