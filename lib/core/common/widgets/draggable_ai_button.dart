import 'package:flutter/material.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/design/app_icons.dart';

class DraggableAiButton extends StatefulWidget {
  final bool visible;
  final double buttonOpacity;

  const DraggableAiButton({
    super.key,
    this.visible = true,
    this.buttonOpacity = 0.5,
  });

  @override
  State<DraggableAiButton> createState() => _DraggableAiButtonState();
}

class _DraggableAiButtonState extends State<DraggableAiButton> {
  // -1..1 alignment; start near bottom-right
  Alignment _alignment = const Alignment(0.88, 0.82);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedOpacity(
        opacity: widget.visible ? widget.buttonOpacity : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Align(
          alignment: _alignment,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                final double newX = (_alignment.x + details.delta.dx / (size.width / 2)).clamp(-0.93, 0.93);
                final double newY = (_alignment.y + details.delta.dy / (size.height / 2)).clamp(-0.93, 0.93);
                _alignment = Alignment(newX, newY);
              });
            },
            onTap: () {},
            child: CustomSvgImage(assetName: AppIcons.aiFloatingButton, height: 48),
          ),
        ),
      ),
    );
  }
}