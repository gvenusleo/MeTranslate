import "package:flutter/material.dart";

/// 选择按钮
class SelectedOutlinedButton extends StatefulWidget {
  final Widget child;
  final List<PopupMenuEntry> items;

  const SelectedOutlinedButton({
    super.key,
    required this.child,
    required this.items,
  });

  @override
  State<SelectedOutlinedButton> createState() => _SelectedOutlinedButtonState();
}

class _SelectedOutlinedButtonState extends State<SelectedOutlinedButton> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: _key,
      onPressed: () {
        final RenderBox button =
            _key.currentContext!.findRenderObject()! as RenderBox;
        final RenderBox overlay = Overlay.of(_key.currentContext!)
            .context
            .findRenderObject()! as RenderBox;
        final Offset offset = Offset(0.0, button.size.height);
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(offset, ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
                ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );
        showMenu(
          context: context,
          position: position,
          items: widget.items,
        );
      },
      child: widget.child,
    );
  }
}
