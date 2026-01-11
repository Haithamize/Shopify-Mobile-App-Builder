import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  const CheckoutWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.onSuccess,
  });

  final String checkoutUrl;
  final VoidCallback onSuccess;

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  late final WebViewController _c;
  bool _handledSuccess = false;

  bool _isThankYouUrl(String url) {
    final u = url.toLowerCase();
    // Shopify thank you URLs often contain: /thank_you or "thank-you"
    // Some stores redirect to /orders/<id> or include "thank_you" query.
    return u.contains('thank_you') ||
        u.contains('thank-you') ||
        u.contains('/orders/') ||
        (u.contains('/checkouts/') && u.contains('thank'));
  }

  void _handleMaybeSuccess(String url) {
    if (_handledSuccess) return;
    if (_isThankYouUrl(url)) {
      _handledSuccess = true;
      widget.onSuccess();
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  void initState() {
    super.initState();

    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _handleMaybeSuccess(url),
          onPageFinished: (url) => _handleMaybeSuccess(url),
          onNavigationRequest: (req) {
            _handleMaybeSuccess(req.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (err) {
            // For PoC just log
            debugPrint('Checkout WebView error: ${err.errorCode} ${err.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: WebViewWidget(controller: _c),
    );
  }
}
