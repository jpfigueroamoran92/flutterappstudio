import 'package:flutter/material.dart';
import 'package:myapp/models/tour.dart';
import 'package:myapp/shared/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:webview_flutter/webview_flutter.dart'; // For WebView

class TourDetailScreen extends StatefulWidget {
  static const String routeName = '/tour-detail';
  final Tour tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  late final WebViewController _webViewController;
  bool _isLoadingWebView = true;
  bool _webViewError = false;

  @override
  void initState() {
    super.initState();
    // Ensure Kuula link is embeddable (often requires specific parameters or format)
    // For this example, we assume kuulaShareLink can be used directly or you might need
    // a separate 'embedUrl' field in your Tour model if Kuula requires it.
    // Basic check: if it doesn't look like a Kuula collection link, don't embed.
    final String embedUrl = widget.tour.kuulaShareLink.contains('kuula.co/share/collection/') 
                            ? widget.tour.kuulaShareLink 
                            : 'about:blank'; // Fallback to blank page if not a Kuula collection

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoadingWebView = true;
              _webViewError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoadingWebView = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print("WebView Error: ${error.description}");
            setState(() {
              _isLoadingWebView = false;
              _webViewError = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow navigation only to Kuula or about:blank initially
            if (request.url.startsWith('https://kuula.co/') || request.url == 'about:blank') {
              return NavigationDecision.navigate;
            }
            // For other links, you might want to launch them externally
            _launchUrlExternal(request.url, context); 
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));

      if (embedUrl == 'about:blank') {
          _isLoadingWebView = false;
          _webViewError = true; // Treat non-Kuula links as an error for embedding
      }
  }

  Future<void> _launchUrlExternal(String url, BuildContext ctx) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace externo: $url'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  Future<void> _copyLinkToClipboard(BuildContext ctx, String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Enlace del tour copiado al portapapeles'),
          backgroundColor: AppColors.secondaryColor,
        ),
      );
    }
  }

  Future<void> _shareLink(BuildContext ctx, String link, String tourName) async {
    try {
      // The boxParameter provides the sourceRect for iPad popovers.
      final box = ctx.findRenderObject() as RenderBox?;
      await Share.share(
        'Echa un vistazo a este recorrido virtual: $tourName - $link',
        subject: 'Recorrido Virtual: $tourName',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      print('Error al compartir: $e');
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Error al compartir el enlace.'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;
    return Scaffold(
      appBar: AppBar(title: Text(tour.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Embedded WebView for Kuula Tour
            AspectRatio(
              aspectRatio: 16 / 10, // Adjust aspect ratio as needed
              child: Stack(
                children: [
                  if (!_webViewError)
                    WebViewWidget(controller: _webViewController)
                  else 
                    Container(
                        color: Colors.grey[200],
                        child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.error_outline, color: Colors.red[700], size: 50),
                                    SizedBox(height: 10),
                                    Text('No se pudo cargar la vista previa del tour.', textAlign: TextAlign.center),
                                    SizedBox(height: 10),
                                    ElevatedButton.icon(
                                        icon: Icon(Icons.open_in_new, size: 18),
                                        label: Text('Abrir en Kuula.co'),
                                        onPressed: () => _launchUrlExternal(tour.kuulaShareLink, context),
                                    )
                                ],
                            )
                        )
                    ),
                  if (_isLoadingWebView && !_webViewError)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              tour.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: AppColors.primaryColor
                  ),
            ),
            const SizedBox(height: 8),
            if (tour.address != null && tour.address!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(child: Text(tour.address!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54))),
                ],
              ),
            const SizedBox(height: 8),
             Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text('Visualizaciones: ${tour.viewsCount}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54)),
                ],
              ),
            const SizedBox(height: 16),
            if (tour.description != null && tour.description!.isNotEmpty) ...[
              Text(
                'Descripción:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 4),
              Text(tour.description!, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
            // Action Buttons
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: <Widget>[
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Abrir en Kuula.co'),
                  onPressed: () => _launchUrlExternal(tour.kuulaShareLink, context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar Enlace'),
                  onPressed: () => _copyLinkToClipboard(context, tour.kuulaShareLink),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Compartir'),
                  onPressed: () => _shareLink(context, tour.kuulaShareLink, tour.name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
