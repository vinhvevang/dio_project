import 'package:flutter/material.dart';
import 'product_model.dart';
import 'product_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _productService = ProductService();

  final List<ProductModel> _products = [];
  int _page = 1;
  final int _limit = 10;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadProducts(reset: true);

    _scrollController.addListener(() {
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 200) {
        if (!_loadingMore && _hasMore) {
          _loadProducts();
        }
      }
    });
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (_loading || _loadingMore) return;

    setState(() {
      if (reset) {
        _loading = true;
        _page = 1;
        _hasMore = true;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final result = await _productService.getProducts(
        page: _page,
        limit: _limit,
      );

      setState(() {
        if (reset) {
          _products.clear();
          _products.addAll(result.products);
        } else {
          _products.addAll(result.products);
        }

        _hasMore = result.products.length == _limit &&
            _products.length < result.count;

        if (_hasMore) {
          _page++;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    await _loadProducts(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading && _products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _products.length + (_loadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _products.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final p = _products[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: p.image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image),
                      title: Text(p.name),
                      subtitle: Text(
                        'Code: ${p.code}\nPrice: ${p.price} | Stock: ${p.stock}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
    );
  }
}