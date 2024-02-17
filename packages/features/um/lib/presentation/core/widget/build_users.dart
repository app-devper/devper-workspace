// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:common/core/ext/widget_ext.dart';

// Project imports:
import 'package:um/domain/entities/user/user.dart';

buildUsers(Future<List<User>> users, Function(User) onTap) {
  buildUserList() {
    return users.toWidgetLoading(
      widgetBuilder: (data) => Expanded(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return ListTile(
              title: Text(item.username),
              subtitle: Text(item.role),
              onTap: () {
                onTap(item);
              },
            );
          },
        ),
      ),
    );
  }

  return Flex(
    direction: Axis.horizontal,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      buildUserList(),
    ],
  );
}
