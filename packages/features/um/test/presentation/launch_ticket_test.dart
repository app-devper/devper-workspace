import 'package:flutter_test/flutter_test.dart';
import 'package:um/presentation/splash/launch_ticket.dart';

void main() {
  test('reads the ticket UM put on /sso', () {
    expect(takeLaunchTicket(Uri.parse('https://pos.devper.app/sso?ticket=t-1')), 't-1');
  });

  test('ignores other paths and missing or oversized tickets', () {
    expect(takeLaunchTicket(Uri.parse('https://pos.devper.app/?ticket=t-1')), isNull);
    expect(takeLaunchTicket(Uri.parse('https://pos.devper.app/sso')), isNull);
    expect(takeLaunchTicket(Uri.parse('https://pos.devper.app/sso?ticket=${'x' * 129}')), isNull);
  });
}
