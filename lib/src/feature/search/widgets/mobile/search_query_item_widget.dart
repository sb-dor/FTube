import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';

/// A suggestion or history row; [onDelete] adds the trash button for history entries.
class SearchQueryItemWidget extends StatelessWidget {
  const SearchQueryItemWidget({required this.query, required this.onTap, super.key, this.onDelete});

  final String query;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.search),
          const SizedBox(width: 10),
          Expanded(child: Text(query, style: const TextStyle(fontSize: 15))),
          if (onDelete case final onDelete?)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                tooltip: Localization.of(context).delete,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(2),
                style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
              ),
            ),
        ],
      ),
    ),
  );
}
