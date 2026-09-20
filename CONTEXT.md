# Devper POS

The till, stock and purchasing language of a Thai pharmacy. One shop runs the
POS app over a counter; `sm` administers the systems behind it.

This file is a glossary. Decisions live in `docs/adr/`; how the code is arranged
lives in `docs/architecture.md`.

## Selling

**Sale**:
One customer's purchase in progress at the till — its lines, its customer, its
prescription details, and the money it comes to.
_Avoid_: cart, basket, transaction

**Till**:
The counter's set of parked Sales and which one is open. A cashier switches
between them when a customer steps away.
_Avoid_: cart store, session, register

**Line**:
One product at one quantity and one price within a Sale.
_Avoid_: cart item, row

**Customer type**:
Which price list a customer buys at — walk-in, regular, or wholesale. A Sale
with no customer sells at the stock's own price.
_Avoid_: tier, segment, group

**Price type**:
The price a Line actually charges, and where it came from: the stock batch it
draws from, or the customer type's price list. A cashier may override it on a
single Line.

**Override**:
A price type a cashier chose by hand on one Line. It survives a change of
customer; a discount is not an override.

**Order**:
A completed Sale, as recorded by the server. Money has changed hands and stock
has moved.
_Avoid_: receipt, sale (once it is done, it is an Order)

## Stock

**Product**:
Something the shop sells, under one or more Units.

**Unit**:
A way a Product is sold — by tablet, by strip, by box — each with its own
barcode and cost.
_Avoid_: SKU, variant

**Stock**:
A batch of one Unit as received, carrying the cost and price it came in at, an
expiry date, and a sequence that decides which batch sells first.
_Avoid_: inventory, batch (in code), lot

**Lot**:
A Stock followed for expiry, so the shop can be warned before it runs out of
shelf life.

**Sold first**:
Quantity sold that no Stock accounted for. It is the shop's unreconciled
bucket, not a batch.

**Oversell**:
Selling more of a Unit than any Stock holds. Permitted per Line, deliberately,
and the shortfall stays attached to the last real batch it touched rather than
falling into sold first.

**Receive**:
A delivery being entered — its supplier, its reference, and its lines — before
it is imported. Importing it moves the goods into Stock and cannot be undone.
_Avoid_: purchase order, GRN, delivery

**Adjustment**:
A correction to a Stock's quantity that is not a sale and not a delivery.

**Count**:
A stock take: what the shelf actually holds, against what the system believes.

**Return**:
Goods coming back from a completed Order, against a specific Line.

## People

**Customer**:
Someone the shop sells to, holding a code, a customer type and — for
prescriptions — an address to print on a receipt.

**Supplier**:
Someone the shop buys from. The shop's own supplier profile is what prints at
the top of a receipt; its absence is a profile not yet set up, not a failure.
_Avoid_: vendor

**Admin**:
The role that may see cost and profit, delete Orders, and edit Products. Any
role that cannot be read is not an Admin.
