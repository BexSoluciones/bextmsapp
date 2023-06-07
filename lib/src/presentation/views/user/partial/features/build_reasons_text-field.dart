import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    Key? key,
    this.onChanged,
    this.searchController,
  }) : super(key: key);

  final TextEditingController? searchController;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.hintColor.withOpacity(.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                autocorrect: false,
                style: theme.textTheme.bodyMedium,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Seleccione el motivo',
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                    color: theme.primaryColor,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
