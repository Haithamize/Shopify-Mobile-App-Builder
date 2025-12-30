import 'package:equatable/equatable.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  final int limit;
  final bool forceRefresh;
  const LoadProducts({required this.limit, this.forceRefresh = false});

  @override
  List<Object?> get props => [limit, forceRefresh];
}
