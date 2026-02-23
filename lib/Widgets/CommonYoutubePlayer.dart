import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CommonYoutubePlayer extends StatefulWidget {
  final String youtubeUrl;
  final double height;
  final String placeholderThumbnail;
  final double borderRadius;

  const CommonYoutubePlayer({
    Key? key,
    required this.youtubeUrl,
    required this.height,
    required this.placeholderThumbnail,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<CommonYoutubePlayer> createState() => _CommonYoutubePlayerState();
}

class _CommonYoutubePlayerState extends State<CommonYoutubePlayer> {
  bool _isPlaying = false;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController();
    
    // These methods throw UnimplementedError on Web
    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              // Prevent navigating away from YouTube in the embed player
              if (request.url.contains('youtube.com') || request.url.contains('googlevideo.com')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        );
    }
  }

  String _getEmbedUrl(String url) {
    String videoId = '';
    
    if (url.contains('embed/')) {
      videoId = url.split('embed/').last.split('?').first;
    } else if (url.contains('v=')) {
      videoId = url.split('v=').last.split('&').first;
    } else if (url.contains('youtu.be/')) {
      videoId = url.split('youtu.be/').last.split('?').first;
    } else {
      // Try to extract from the end of the URL if it's just an ID
      videoId = url.split('/').last.split('?').first;
    }
    
    return 'https://www.youtube.com/embed/$videoId?autoplay=1&rel=0&showinfo=0';
  }

  @override
  void didUpdateWidget(CommonYoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.youtubeUrl != widget.youtubeUrl) {
      if (_isPlaying) {
        _controller.loadRequest(Uri.parse(_getEmbedUrl(widget.youtubeUrl)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) {
      return GestureDetector(
        onTap: () {
          _controller.loadRequest(Uri.parse(_getEmbedUrl(widget.youtubeUrl)));
          setState(() {
            _isPlaying = true;
          });
        },
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            image: DecorationImage(
              image: NetworkImage(widget.placeholderThumbnail),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                color: Colors.black.withOpacity(0.2),
              ),
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: WebViewWidget(controller: _controller),
    );
  }
}
