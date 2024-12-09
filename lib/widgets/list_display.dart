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
                      '₱${NumberFormat("#,##0.00", "en_US").format(expense['amount'])}',
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
  final TextEditingController _percentageController = TextEditingController();

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

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
                  shadowColor: isBudgetMaxed || isBudgetExpired ? Colors.red : progressColor,
                  surfaceTintColor: isBudgetMaxed || isBudgetExpired ? Colors.red : Colors.transparent,
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
                            'Spending: ₱${NumberFormat("#,##0.00", "en_US").format(spentAmount)}\nBudget: ₱${NumberFormat("#,##0.00", "en_US").format(amount)}',
                          ),
                          trailing: (isBudgetExpired && isBudgetMaxed)
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
                              : (isBudgetExpired && !isBudgetMaxed)
                              ? IconButton(
                            icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                            onPressed: () {
                              // Open modal bottom sheet for transferring funds
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                      left: 20.0,
                                      right: 20.0,
                                      top: 20.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: _percentageController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Enter percentage for prioritized goals',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        ElevatedButton(
                                          onPressed: () async {
                                            double remainingFunds = amount - spentAmount;
                                            double? percentage = double.tryParse(_percentageController.text);

                                            if (percentage == null || percentage < 0 || percentage > 100) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please enter a valid percentage between 0 and 100.'),
                                                ),
                                              );
                                              return;
                                            }

                                            // Distribute funds to goals
                                            await widget.firebaseServices.distributeFundsToGoals(
                                              widget.selectedAccount!,
                                              remainingFunds,
                                              percentage,
                                            );

                                            // Delete the budget after transferring funds
                                            await widget.firebaseServices.deleteBudget(
                                              widget.selectedAccount!,
                                              budget['id'],
                                            );

                                            Navigator.pop(context);
                                          },
                                          child: const Text('Distribute Funds'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
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
  bool showArchived = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showButtons)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showGoals = true;
                      showArchived = false;
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
                        fontSize: 11.0,
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
                      showArchived = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: !showGoals && !showArchived ? Colors.transparent : Colors.grey.shade300)),
                    backgroundColor: !showGoals && !showArchived ? kBlueColor : Colors.white,
                  ),
                  child: Text(
                    'History',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: !showGoals && !showArchived ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showArchived = true;
                      showGoals = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: showArchived ? Colors.transparent : Colors.grey.shade300)),
                    backgroundColor: showArchived ? kBlueColor : Colors.white,
                  ),
                  child: Text(
                    'Archived',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: showArchived ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        Flexible(
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: showGoals
                ? widget.firebaseServices.getUserGoalsListView(widget.selectedAccount)
                : showArchived
                ? widget.firebaseServices.getArchivedGoalsListView(widget.selectedAccount)
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
                allItems.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aPriority = aData['isPrioritized'] ?? false;
                  final bPriority = bData['isPrioritized'] ?? false;
                  if (aPriority && !bPriority) return -1;
                  if (!aPriority && bPriority) return 1;
                  return 0;
                });
                final items = widget.showLatestOnly ? allItems.take(2).toList() : allItems;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final itemData = item.data() as Map<String, dynamic>;

                    if (showGoals || showArchived) {
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
                                  'Saved: ₱${NumberFormat("#,##0.00", "en_US").format(itemData['amountSaved'])}\nTarget Amount: ₱${NumberFormat("#,##0.00", "en_US").format(itemData['targetAmount'])}',),
                                trailing: savedAmount >= targetAmount
                                    ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        bool? confirmDelete = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Delete Goal'),
                                              content: const Text('Are you sure you want to delete this goal?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmDelete == true) {
                                          if (showArchived) {
                                            await widget.firebaseServices.deleteArchivedGoal(widget.selectedAccount, item.id);
                                          } else {
                                            await widget.firebaseServices.deleteGoal(widget.selectedAccount, item.id);
                                          }
                                          setState(() {});
                                        }
                                      },
                                    ),
                                    if (!showArchived)
                                      IconButton(
                                        icon: const Icon(Icons.archive, color: Colors.grey),
                                        onPressed: () async {
                                          bool? confirmArchive = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Archive Goal'),
                                                content: const Text('Are you sure you want to archive this goal?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: const Text('Archive'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmArchive == true) {
                                            await widget.firebaseServices.archiveGoal(widget.selectedAccount, item.id);
                                            setState(() {});
                                          }
                                        },
                                      ),
                                  ],
                                )
                                    : IconButton(
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
                                trailing: itemData['isPrioritized'] == true
                                    ? const Icon(Icons.star, color: Colors.amber)
                                    : null,
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
                            title: Text(toGoalName),
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

class AddFundsModal extends StatefulWidget {
  final double screenHeight;
  final String goalId;
  final FirebaseAuthService firebaseServices;
  final String selectedAccount;

  const AddFundsModal({
    super.key,
    required this.screenHeight,
    required this.goalId,
    required this.firebaseServices,
    required this.selectedAccount,
  });

  @override
  State<AddFundsModal> createState() => _AddFundsModalState();
}

class _AddFundsModalState extends State<AddFundsModal> {
  final TextEditingController _addFundsController = TextEditingController();
  bool _isActive = true;

  @override
  void dispose() {
    _isActive = false;
    _addFundsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.screenHeight * 0.8,
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
                      double accountFunds = await widget.firebaseServices.getAccountFunds(widget.selectedAccount);
                      if (accountFunds >= amount) {
                        // If funds are sufficient, add funds to the goal
                        await widget.firebaseServices.addGoalFunds(widget.selectedAccount, widget.goalId, amount);

                        // Fetch updated goal data to verify if the goal is achieved
                        DocumentSnapshot goalSnapshot =
                            await widget.firebaseServices.getGoalById(widget.selectedAccount, widget.goalId);
                        double savedAmount = (goalSnapshot['amountSaved'] as num).toDouble();
                        double targetAmount = (goalSnapshot['targetAmount'] as num).toDouble();

                        // Close the AddFundsModal
                        if (_isActive) {
                          Navigator.pop(context);
                        }

                        // Show congratulatory message if goal is achieved
                        if (_isActive && savedAmount >= targetAmount) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'images/congratulations.png',
                                      height: 150,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Congratulations',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Goal achieved!',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Continue'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      } else {
                        // If funds are insufficient, close the modal and show an alert dialog
                        if (_isActive) {
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
