// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:design_system/widgets/title_bar.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/customer/customer.dart';

// Project imports:

class CustomerDetailWidget extends StatefulWidget {
  final Customer customer;
  final Function() onBack;
  final Function() onEdit;
  final Function() onClickEdit;

  const CustomerDetailWidget({
    super.key,
    required this.onBack,
    required this.customer,
    required this.onEdit,
    required this.onClickEdit,
  });

  @override
  State<StatefulWidget> createState() => _CustomerDetailWidgetState();
}

class _CustomerDetailWidgetState extends State<CustomerDetailWidget> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          title: widget.customer.name,
          onBack: () {
            widget.onBack();
          },
          action: "แก้ไข",
          onAction: () {
            widget.onClickEdit();
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: buildTabBar(),
        )
      ],
    );
  }

  Widget buildTabBar() {
    return Column(
      children: <Widget>[
        Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            const Divider(height: 1),
            TabBar.secondary(
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              isScrollable: false,
              labelColor: Colors.black,
              controller: _tabController,
              tabs: const <Widget>[
                Tab(
                  height: 36,
                  child: Text('ข้อมูลทั่วไป', maxLines: 1),
                ),
                Tab(
                  height: 36,
                  child: Text('ประวัติการซื้อ', maxLines: 1),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildCustomerInfo(widget.customer),
                    ],
                  )),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: const Center(child: Text('ประวัติการซื้อ tab')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(Customer customer) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          _buildListItem('ประเภทลูกค้า', findCustomerType(customer.type).name),
          _buildListItem('หมายเลขลูกค้า', customer.code),
          _buildListItem('ชื่อลูกค้า', customer.name),
          _buildListItem('ที่อยู่', customer.address),
          _buildListItem('โทรศัพท์', customer.phone),
          _buildListItem('อีเมล', customer.email),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String subtitle) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
          trailing: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1),
        )
      ],
    );
  }
}
