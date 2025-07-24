import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebViewScreen extends StatefulWidget {
  final String snapToken;
  final VoidCallback onFinish;

  const MidtransWebViewScreen({
    super.key,
    required this.snapToken,
    required this.onFinish,
  });

  @override
  State<MidtransWebViewScreen> createState() => _MidtransWebViewScreenState();
}

class _MidtransWebViewScreenState extends State<MidtransWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  // Ubah URL ini sesuai dengan Finish URL dari Dashboard Midtrans kamu
  final String finishUrl = 'https://midtrans-backend-1.onrender.com/finish';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith(finishUrl) ||
                request.url.contains('transaction_status=settlement') ||
                request.url.contains('status_code=200')) {
              // Deteksi redirect selesai (sandbox / production)
              widget.onFinish();
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
