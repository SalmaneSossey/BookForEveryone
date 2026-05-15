import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/models/gloss_entry.dart';
import '../../../core/theme/app_colors.dart';

class CwasaAvatarWidget extends StatefulWidget {
  const CwasaAvatarWidget({
    required this.glosses,
    required this.currentGloss,
    this.replayNonce = 0,
    this.onSignedGloss,
    super.key,
  });

  final List<GlossEntry> glosses;
  final GlossEntry? currentGloss;
  final int replayNonce;
  final ValueChanged<String>? onSignedGloss;

  @override
  State<CwasaAvatarWidget> createState() => _CwasaAvatarWidgetState();
}

class _CwasaAvatarWidgetState extends State<CwasaAvatarWidget> {
  WebViewController? _controller;
  String? _lastSequenceSignature;
  String? _lastHighlightSignature;
  bool _pageReady = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(CwasaAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sendSequenceIfNeeded(force: widget.replayNonce != oldWidget.replayNonce);
    _sendHighlightIfNeeded();
  }

  Future<void> _loadAvatar() async {
    final html =
        await rootBundle.loadString('assets/cwasa/signbook_avatar.html');
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.ink)
      ..addJavaScriptChannel(
        'SignBook',
        onMessageReceived: (message) {
          try {
            final decoded = jsonDecode(message.message) as Map<String, dynamic>;
            if (decoded['type'] == 'sign') {
              final gloss = decoded['gloss'] as String? ?? '';
              final word = decoded['word'] as String? ?? '';
              widget.onSignedGloss?.call(gloss.isEmpty ? word : gloss);
            } else if (decoded['type'] == 'diagnostic') {
              debugPrint(
                'CWASA ${decoded['status']}: ${decoded['detail'] ?? ''}',
              );
            }
          } catch (_) {
            widget.onSignedGloss?.call(message.message);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _pageReady = true;
            _sendSequenceIfNeeded(force: true);
            _sendHighlightIfNeeded(force: true);
          },
        ),
      );

    await controller.loadHtmlString(
      html,
      baseUrl: 'https://vhg.cmp.uea.ac.uk/tech/jas/vhg2023/cwa/',
    );

    if (!mounted) {
      return;
    }
    setState(() => _controller = controller);
    _sendSequenceIfNeeded(force: true);
    _sendHighlightIfNeeded(force: true);
  }

  void _sendSequenceIfNeeded({bool force = false}) {
    final controller = _controller;
    if (!_pageReady || controller == null) {
      return;
    }

    final signature = widget.glosses
        .map((entry) => '${entry.word}|${entry.gloss}|${entry.available}')
        .join('::');
    if (!force && signature == _lastSequenceSignature) {
      return;
    }

    _lastSequenceSignature = signature;
    final payload =
        jsonEncode(widget.glosses.map((entry) => entry.toJson()).toList());
    controller.runJavaScript('window.playGlossSequence($payload);');
  }

  void _sendHighlightIfNeeded({bool force = false}) {
    final controller = _controller;
    final gloss = widget.currentGloss;
    if (!_pageReady || controller == null || gloss == null) {
      return;
    }

    final signature = '${gloss.word}|${gloss.available}';
    if (!force && signature == _lastHighlightSignature) {
      return;
    }

    _lastHighlightSignature = signature;
    controller.runJavaScript(
      'window.highlightGloss(${jsonEncode(gloss.word)}, ${gloss.available});',
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.ink),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null) WebViewWidget(controller: controller),
            if (controller == null || !_pageReady)
              const _AvatarLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _AvatarLoadingOverlay extends StatelessWidget {
  const _AvatarLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 150,
            height: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.teal, width: 3),
            ),
            child: const Icon(
              Icons.sign_language,
              color: Colors.white,
              size: 76,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Loading CWASA avatar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Using visual fallback if the WebGL runtime is unavailable',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
          ),
        ],
      ),
    );
  }
}
