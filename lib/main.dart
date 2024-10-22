import 'package:flutter/material.dart';

void main() {
  runApp(BankApp());
}

class BankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PS Bank App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// Home page with navigation drawer
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AccountForm(),
    DepositForm(),
    AccountSummary(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('P\'s Bank App'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'New Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Deposit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Account Summary',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Customer class to store account information
class Customer {
  String name;
  String accountType;
  double balance;

  Customer(this.name, this.accountType, this.balance);
}

class Bank {
  static final List<Customer> customers = [];
  static final List<String> transactionHistory = [];

  static void addCustomer(Customer customer) {
    customers.add(customer);
    transactionHistory.add('Account created for ${customer.name}');
  }

  static void deposit(Customer customer, double amount) {
    customer.balance += amount;
    transactionHistory.add('${customer.name} deposited ₹$amount');
  }
}

// Form 1: Create a new account
class AccountForm extends StatefulWidget {
  @override
  _AccountFormState createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _accountType = 'Savings';
  double _balance = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration:const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                _name = value!;
              },
            ),
            DropdownButtonFormField<String>(
              value: _accountType,
              decoration:const InputDecoration(labelText: 'Account Type'),
              items: ['Savings', 'Current']
                  .map((String accountType) => DropdownMenuItem<String>(
                        value: accountType,
                        child: Text(accountType),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _accountType = newValue!;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Initial Deposit'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                _balance = double.parse(value!);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Customer customer = Customer(_name, _accountType, _balance);
                  Bank.addCustomer(customer);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Account created for $_name')));
                }
              },
              child:const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

// Form 2: Deposit money
class DepositForm extends StatefulWidget {
  @override
  _DepositFormState createState() => _DepositFormState();
}

class _DepositFormState extends State<DepositForm> {
  final _formKey = GlobalKey<FormState>();
  double _depositAmount = 0.0;
  Customer? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<Customer>(
              decoration: const InputDecoration(labelText: 'Select Customer'),
              items: Bank.customers
                  .map((Customer customer) => DropdownMenuItem<Customer>(
                        value: customer,
                        child: Text(customer.name),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCustomer = newValue!;
                });
              },
            ),
            TextFormField(
              decoration:const InputDecoration(labelText: 'Deposit Amount'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                _depositAmount = double.parse(value!);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _selectedCustomer != null) {
                  _formKey.currentState!.save();
                  Bank.deposit(_selectedCustomer!, _depositAmount);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '₹$_depositAmount deposited to ${_selectedCustomer!.name}')));
                }
              },
              child:const Text('Deposit Money'),
            ),
          ],
        ),
      ),
    );
  }
}

// Form 3: Account summary
class AccountSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: Bank.transactionHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(Bank.transactionHistory[index]),
          );
        },
      ),
    );
  }
}
