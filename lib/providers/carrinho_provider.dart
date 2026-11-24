import 'package:flutter/foundation.dart';
import '../models/produto.dart';

class CarrinhoProvider extends ChangeNotifier {
  final List<Produto> _itens = [];
  final Map<String, int> _quantidades = {};

  double _desconto = 0.0;

  List<Produto> get itens => List.unmodifiable(_itens);

  int get quantidade {
    return _quantidades.values.fold(0, (total, qtd) => total + qtd);
  }

  double get valorTotal {
    return _itens.fold(
      0.0,
      (total, item) =>
          total + item.preco * (_quantidades[item.id] ?? 0),
    );
  }

  double get desconto => _desconto;

  double get valorComDesconto {
    return valorTotal * (1 - _desconto);
  }

  int quantidadeDoProduto(Produto produto) {
    return _quantidades[produto.id] ?? 0;
  }

  void adicionar(Produto produto) {
    if (!_itens.contains(produto)) {
      _itens.add(produto);
      _quantidades[produto.id] = 1;
    } else {
      aumentar(produto);
      return;
    }

    notifyListeners();
  }

  void aumentar(Produto produto) {
    if (!_itens.contains(produto)) {
      _itens.add(produto);
      _quantidades[produto.id] = 1;
    } else {
      _quantidades[produto.id] =
          quantidadeDoProduto(produto) + 1;
    }

    notifyListeners();
  }

  void diminuir(Produto produto) {
    final qtd = quantidadeDoProduto(produto);

    if (qtd > 1) {
      _quantidades[produto.id] = qtd - 1;
    } else {
      _itens.remove(produto);
      _quantidades.remove(produto.id);
    }

    notifyListeners();
  }

  void remover(Produto produto) {
    _itens.remove(produto);
    _quantidades.remove(produto.id);
    notifyListeners();
  }

  void aplicarCupom(String cupom) {
    if (cupom.trim().toUpperCase() == 'DESCONTO10') {
      _desconto = 0.10;
    } else {
      _desconto = 0.0;
    }

    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    _quantidades.clear();
    _desconto = 0.0;
    notifyListeners();
  }
}