import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finedger/constants/constants.dart';
import 'package:finedger/providers/account_provider.dart';
import 'package:finedger/providers/page_provider.dart';
import 'package:finedger/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ExpenseListWidget extends StatefulWidget {
  final FirebaseAuthService firebaseServices;
  final String? selectedAccount;
  final bool showLatestOnly;

  const ExpenseListWidget({
    super.key,
    required this.firebaseServices,
    required this.selectedAccount,
    this.showLatestOnly = false,
  });

  @override
  State<ExpenseListWidget> createState() => _ExpenseListWidgetState();
}

class _ExpenseListWidgetState extends State<ExpenseListWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.firebaseServices.getUserExpenses(widget.selectedAccount),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error: \${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No expense found"));
        } else {
          final allExpenses = snapshot.data!;
          final expenses = widget.showLatestOnly ? allExpenses.take(2).toList() : allExpenses;

          return ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(expense['date']);
              String expenseDate = DateFormat('MMMM d').format(dateTime);
              int colorValue = (expense['color'] is int) ? expense['color'] : (expense['color'] as Color).value;
              Color color = Color(colorValue);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  elevation: 4,
                  surfaceTintColor: color,
                  shadowColor: color,
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(child: Text(expense['description'][0])),
                    title: Text(expense['description'] ?? 'No Description'),
                    subtitle: Text(
                      '${expense['category'] ?? 'No category'}, $expenseDate',
                      style: const TextStyle(fontSize: 12.0, color: kGrayColor),
                    ),
                    trailing: Text(
                      'P${expense['amount'].toString()}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class BudgetListWidget extends StatefulWidget {
  const BudgetListWidget({
    super.key,
    required this.firebaseServices,
    required this.selectedAccount,
    this.showLatestOnly = false,
  });

  final FirebaseAuthService firebaseServices;
  final String? selectedAccount;
  final bool showLatestOnly;

  @override
  State<BudgetListWidget> createState() => _BudgetListWidgetState();
}

class _BudgetListWidgetState extends State<BudgetListWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.watch<AccountProvider>().selectedAccount != null
          ? widget.firebaseServices.getUserBudgets(context.watch<AccountProvider>().selectedAccount!)
          : null, // No stream if no account is selected
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No budget found"));
        } else {
          final allBudgets = snapshot.data!;
          final budgets = widget.showLatestOnly ? allBudgets.take(2).toList() : allBudgets;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final String description = budget['description'] ?? 'No description';
              final double spentAmount = budget['spentAmount']?.toDouble() ?? 0.0;
              final double amount = budget['amount']?.toDouble() ?? 1.0; // Avoid division by zero
              final double progressPercentage = (spentAmount / amount) * 100;
              DateTime startDate = DateTime.fromMillisecondsSinceEpoch(budget['startDate']);
              DateTime endDate = DateTime.fromMillisecondsSinceEpoch(budget['endDate']);
              String textStartDate = DateFormat('MMMM d, y').format(startDate);
              String textEndDate = DateFormat('MMMM d, y').format(endDate);
              int colorValue;
              if (budget['color'] is int) {
                colorValue = budget['color'];
              } else if (budget['color'] is Color) {
                colorValue = (budget['color'] as Color).value;
              } else {
                colorValue = kBlueColor.value; // Use a default color value if none exists
              }
              Color progressColor = Color(colorValue);

              bool isBudgetMaxed = spentAmount >= amount;
              bool isBudgetExpired =
                  budget['endDate'] != null && (budget['endDate'] as num) <= DateTime.now().millisecondsSinceEpoch;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4.0,
                  shadowColor: progressColor,
                  surfaceTintColor: progressColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          isThreeLine: true,
                          leading: CircleAvatar(child: Text(description[0])),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(description, overflow: TextOverflow.ellipsis),
                              if (isBudgetExpired)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Budget Expired',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              else if (isBudgetMaxed)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Budget Maxed',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            'Spending: ₱${spentAmount.toStringAsFixed(2)}\nBudget: ₱${amount.toStringAsFixed(2)}',
                          ),
                          trailing: (isBudgetExpired || isBudgetMaxed)
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.refresh, color: Colors.green),
                                      onPressed: () async {
                                        // Show a confirmation dialog before renewing
                                        bool? confirmRenew = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Renew budget?'),
                                              content: const Text(
                                                  'This will reset current spending and set new start and end date.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false); // Cancel renew
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true); // Confirm renew
                                                  },
                                                  child: const Text('Renew'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        // Proceed with renewal if confirmed
                                        if (confirmRenew == true) {
                                          // Calculate new start and end date
                                          DateTime newStartDate = DateTime.now();
                                          Duration duration = endDate.difference(startDate);
                                          DateTime newEndDate = newStartDate.add(duration);

                                          // Update the budget with the renewed values
                                          await widget.firebaseServices.updateBudget(
                                            widget.selectedAccount!,
                                            budget['id'],
                                            {
                                              'spentAmount': 0.0,
                                              'startDate': newStartDate.millisecondsSinceEpoch,
                                              'endDate': newEndDate.millisecondsSinceEpoch,
                                            },
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Color(0xFFf94252)),
                                      onPressed: () async {
                                        // Show a confirmation dialog before deleting
                                        bool? confirmDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Delete budget?'),
                                              content: const Text('This cannot be undone.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false); // Cancel delete
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true); // Confirm delete
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        // Proceed with deletion if confirmed
                                        if (confirmDelete == true) {
                                          await widget.firebaseServices
                                              .deleteBudget(widget.selectedAccount!, budget['id']);
                                        }
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: SfLinearGauge(
                                minimum: 0,
                                maximum: amount,
                                showTicks: false,
                                showLabels: false,
                                axisTrackStyle: LinearAxisTrackStyle(
                                  edgeStyle: LinearEdgeStyle.bothCurve,
                                  thickness: 8,
                                  color: Colors.grey[300],
                                ),
                                barPointers: [
                                  LinearBarPointer(
                                    value: spentAmount,
                                    color: progressColor,
                                    thickness: 8,
                                    edgeStyle: LinearEdgeStyle.bothCurve,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              '${progressPercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                            )
                          ],
                        ),
                        const Divider(),
                        ListTile(
                          dense: true,
                          subtitle: Text('Start Date: $textStartDate \nEnd Date: $textEndDate'),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class GoalsListWidget extends StatefulWidget {
  final FirebaseAuthService firebaseServices;
  final String selectedAccount;
  final double screenHeight;
  final bool showLatestOnly;
  final bool showButtons;

  const GoalsListWidget({
    super.key,
    required this.firebaseServices,
    required this.selectedAccount,
    this.showLatestOnly = false,
    required this.screenHeight,
    this.showButtons = true,
  });

  @override
  State<GoalsListWidget> createState() => _GoalsListWidgetState();
}

class _GoalsListWidgetState extends State<GoalsListWidget> {
  bool showGoals = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showButtons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showGoals = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: showGoals ? Colors.transparent : Colors.grey.shade300)),
                      backgroundColor: showGoals ? kBlueColor : Colors.white,
                    ),
                    child: Text('Goals',
                        style: TextStyle(
                          color: showGoals ? Colors.white : Colors.black,
                        )),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showGoals = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: !showGoals ? Colors.transparent : Colors.grey.shade300)),
                      backgroundColor: !showGoals ? kBlueColor : Colors.white,
                    ),
                    child: Text(
                      'History',
                      style: TextStyle(
                        color: !showGoals ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        Flexible(
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: showGoals
                ? widget.firebaseServices.getUserGoalsListView(widget.selectedAccount)
                : widget.firebaseServices.getGoalFundsHistory(widget.selectedAccount),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LinearProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No data available"));
              } else {
                final allItems = snapshot.data!;
                final items = widget.showLatestOnly ? allItems.take(2).toList() : allItems;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final itemData = item.data() as Map<String, dynamic>;

                    if (showGoals) {
                      // Display goal information
                      DateTime startDate = DateTime.fromMillisecondsSinceEpoch(item['startDate']);
                      DateTime endDate = DateTime.fromMillisecondsSinceEpoch(item['endDate']);
                      String textStartDate = DateFormat('MMMM d, y').format(startDate);
                      String textEndDate = DateFormat('MMMM d, y').format(endDate);
                      double savedAmount = item['amountSaved'] ?? 0.0;
                      double targetAmount = item['targetAmount'] ?? 1.0;
                      double progress = (savedAmount / targetAmount) * 100;
                      int colorValue = itemData['color'] ?? kBlueColor.value;
                      Color progressColor = Color(colorValue);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 4.0,
                          shadowColor: progressColor,
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: SfRadialGauge(
                                    axes: <RadialAxis>[
                                      RadialAxis(
                                        minimum: 0,
                                        maximum: 100,
                                        startAngle: 270,
                                        endAngle: 270,
                                        showLabels: false,
                                        showTicks: false,
                                        axisLineStyle: AxisLineStyle(
                                          thickness: 0.15,
                                          color: Colors.grey[300]!,
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            value: progress.clamp(0, 100),
                                            width: 0.15,
                                            sizeUnit: GaugeSizeUnit.factor,
                                            color: progressColor,
                                            enableAnimation: true,
                                          )
                                        ],
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                            widget: Text(
                                              "${progress.toStringAsFixed(0)}%",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            angle: 90,
                                            positionFactor: 0.1,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                isThreeLine: true,
                                title: Text(itemData['description'] ?? 'No description'),
                                subtitle: Text(
                                    'Saved: ₱${itemData['amountSaved']} \nTarget Amount: ₱${itemData['targetAmount']}'),
                                trailing: IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ClipRRect(
                                          child: AddFundsModal(
                                            screenHeight: widget.screenHeight,
                                            goalId: item.id,
                                            firebaseServices: widget.firebaseServices,
                                            selectedAccount: widget.selectedAccount,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(FontAwesomeIcons.plus),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                dense: true,
                                subtitle: Text('Start Date: $textStartDate \nEnd Date: $textEndDate'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Display history information
                      DateTime fundDate = DateTime.fromMillisecondsSinceEpoch(item['date']);
                      String formattedDate = DateFormat('MMMM d, y').format(fundDate);
                      double addedAmount = item['addedAmount'] ?? 0.0;
                      String toGoalName = item['goalName'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 4.0,
                          shadowColor: kBlueColor,
                          child: ListTile(
                            isThreeLine: true,
                            title: Text('$toGoalName'),
                            subtitle: Text('Added Amount: ₱${addedAmount.toStringAsFixed(2)}\nDate: $formattedDate'),
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class AddFundsModal extends StatelessWidget {
  final double screenHeight;
  final String goalId;
  final FirebaseAuthService firebaseServices;
  final String selectedAccount;

  final TextEditingController _addFundsController = TextEditingController();

  AddFundsModal({
    super.key,
    required this.screenHeight,
    required this.goalId,
    required this.firebaseServices,
    required this.selectedAccount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.8,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Opacity(
                opacity: 0.0,
                child: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: null,
                ),
              ),
              const Flexible(
                child: Text(
                  'Add funds to your goal',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.xmark,
                  color: kGrayColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40.0,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field is required";
                      }
                      return null;
                    },
                    controller: _addFundsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        FontAwesomeIcons.pesoSign,
                        color: kGrayColor,
                      ),
                      hintText: '00.00',
                      hintStyle: const TextStyle(color: kGrayColor, fontWeight: FontWeight.w300, fontSize: 15.0),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kGrayColor)),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity,
                  height: 45.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      backgroundColor: kBlueColor,
                    ),
                    onPressed: () async {
                      double amount = double.parse(_addFundsController.text.replaceAll(",", ""));
                      _addFundsController.clear();

                      // Check if the selected account has sufficient funds
                      double accountFunds = await firebaseServices.getAccountFunds(selectedAccount);
                      if (accountFunds >= amount) {
                        // If funds are sufficient, add funds to the budget
                        await firebaseServices.addGoalFunds(selectedAccount, goalId, amount);
                        Navigator.pop(context); // Close the modal
                      } else {
                        // If funds are insufficient, close the modal and show an alert dialog
                        Navigator.pop(context); // Close the modal first
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Insufficient Funds!'),
                              content: const Text(
                                  'You do not have sufficient funds in the selected account to add this amount.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      'Add funds',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
