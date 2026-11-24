import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/produto.dart';
import 'providers/carrinho_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CarrinhoProvider(),
      child: const CarrinhoApp(),
    ),
  );
}

class CarrinhoApp extends StatelessWidget {
  const CarrinhoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinho com Provider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const CatalogoScreen(),
    );
  }
}

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  final List<Produto> _produtos = const [
    Produto(id: '1', nome: 'Teclado Mecânico', preco: 250.00),
    Produto(id: '2', nome: 'Mouse Gamer', preco: 120.00),
    Produto(id: '3', nome: 'Monitor 24"', preco: 890.00),
    Produto(id: '4', nome: 'Headset Stereo', preco: 180.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarrinhoScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CarrinhoProvider>(
                  builder: (context, carrinho, child) {
                    return carrinho.quantidade == 0
                        ? const SizedBox()
                        : CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              '${carrinho.quantidade}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _produtos.length,
        itemBuilder: (context, index) {
          final prod = _produtos[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              title: Text(
                prod.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'R\$ ${prod.preco.toStringAsFixed(2)}',
              ),
              trailing: Consumer<CarrinhoProvider>(
                builder: (context, carrinho, child) {
                  final estaNoCarrinho =
                      carrinho.quantidadeDoProduto(prod) > 0;

                  return IconButton(
                    icon: Icon(
                      estaNoCarrinho
                          ? Icons.check_circle
                          : Icons.add_shopping_cart,
                      color: estaNoCarrinho
                          ? Colors.green
                          : Colors.teal,
                    ),
                    onPressed: () {
                      carrinho.adicionar(prod);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class CarrinhoScreen extends StatefulWidget {
  const CarrinhoScreen({super.key});

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  final TextEditingController cupomController =
      TextEditingController();

  @override
  void dispose() {
    cupomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Carrinho'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CarrinhoProvider>(
        builder: (context, carrinho, child) {
          if (carrinho.quantidade == 0) {
            return const Center(
              child: Text(
                'Seu carrinho está vazio!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: carrinho.itens.length,
                  itemBuilder: (context, index) {
                    final item = carrinho.itens[index];
                    final qtd =
                        carrinho.quantidadeDoProduto(item);

                    return ListTile(
                      title: Text(item.nome),
                      subtitle: Text(
                        'R\$ ${item.preco.toStringAsFixed(2)} x $qtd',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              carrinho.diminuir(item);
                            },
                          ),
                          Text('$qtd'),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              carrinho.aumentar(item);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cupomController,
                        decoration: const InputDecoration(
                          labelText: 'Digite seu cupom',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        carrinho.aplicarCupom(
                          cupomController.text,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              carrinho.desconto > 0
                                  ? 'Cupom aplicado com sucesso!'
                                  : 'Cupom inválido!',
                            ),
                          ),
                        );
                      },
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.teal.shade50,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text(
                          'R\$ ${carrinho.valorTotal.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Desconto:'),
                        Text(
                          '${(carrinho.desconto * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${carrinho.valorComDesconto.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    'Limpar carrinho?',
                                  ),
                                  content: const Text(
                                    'Tem certeza de que deseja remover todos os produtos?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        carrinho.limpar();
                                        cupomController.clear();
                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Carrinho limpo com sucesso!',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Confirmar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Limpar carrinho'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              carrinho.limpar();
                              cupomController.clear();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Compra finalizada com sucesso!',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Finalizar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}