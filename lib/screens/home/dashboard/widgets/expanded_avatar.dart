import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ExpandableAvatar extends StatefulWidget {
  final double avatarSize;
  final String? imageUrl;
  final Widget collapsedChild;
  final double expandedSize;

  const ExpandableAvatar({
    super.key,
    required this.avatarSize,
    required this.collapsedChild,
    this.imageUrl,
    this.expandedSize = 220,
  });

  @override
  State<ExpandableAvatar> createState() => _ExpandableAvatarState();
}

class _ExpandableAvatarState extends State<ExpandableAvatar>
    with SingleTickerProviderStateMixin {
  final GlobalKey _avatarKey = GlobalKey();
  late final AnimationController _controller;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  Rect _avatarRect() {
    final box = _avatarKey.currentContext!.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero);
    return origin & box.size;
  }

  void _open() {
    final overlayState = Overlay.of(context);
    final beginRect = _avatarRect();
    final screenSize = MediaQuery.of(context).size;
    final endRect = Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2),
      width: widget.expandedSize,
      height: widget.expandedSize,
    );
    final beginRadius = beginRect.width / 2;
    const endRadius = 24.0;

    _overlayEntry = OverlayEntry(
      builder: (_) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final curve = Curves.easeOutBack.transform(_controller.value);
            final linear = _controller.value;
            final rect = Rect.lerp(beginRect, endRect, curve)!;
            final radius = beginRadius + (endRadius - beginRadius) * linear;

            return Stack(
              children: [
                // Barrier: dims + blocks all previous content/taps
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _close,
                    child: Container(
                      color: Colors.black.withOpacity(0.55 * linear),
                    ),
                  ),
                ),
                // The popped-out image
                Positioned(
                  left: rect.left,
                  top: rect.top,
                  width: rect.width.clamp(0, double.infinity),
                  height: rect.height.clamp(0, double.infinity),
                  child: GestureDetector(
                    onTap: _close,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: Material(
                        elevation: 8,
                        child: widget.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: widget.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xffFFD84E),
                                child: const Icon(Icons.person, size: 60),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    overlayState.insert(_overlayEntry!);
    _controller.forward(from: 0);
  }

  void _close() {
    _controller.reverse().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _avatarKey,
      onTap: _open,
      child: widget.collapsedChild,
    );
  }
}
