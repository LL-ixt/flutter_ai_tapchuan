import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayScreen> createState() => _VideoPlayScreenState();
}

class _VideoPlayScreenState extends State<VideoPlayScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {
              _initialized = true;
            });
            _controller.play();
            _controller.setLooping(true);
          })
          .catchError((error) {
            debugPrint("Error initializing video player: $error");
            if (!mounted) return;
            setState(() {
              _hasError = true;
            });
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _hasError
            ? const Text(
                'Không thể tải video',
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
            : _initialized
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  _VideoControls(controller: _controller),
                ],
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoControls({required this.controller});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onVideoProgress);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoProgress);
    super.dispose();
  }

  void _onVideoProgress() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final position = value.position;
    final duration = value.duration;

    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            widget.controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.blueAccent,
              bufferedColor: Colors.white30,
              backgroundColor: Colors.white10,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (value.isPlaying) {
                      widget.controller.pause();
                    } else {
                      widget.controller.play();
                    }
                  });
                },
              ),
              Text(
                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              IconButton(
                icon: Icon(
                  value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    widget.controller.setVolume(value.volume == 0 ? 1.0 : 0.0);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
