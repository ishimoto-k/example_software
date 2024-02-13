import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePageView(title: 'Flutter Demo Home Page'),
    );
  }
}

class NumberModel{
  int number;
  NumberModel(this.number);
}
class CounterModel{
  int number;
  CounterModel(this.number);
}

class NumberRepository{
  NumberModel _model = NumberModel(0);
  void setNumber(int c){
    _model.number = c;
  }
  int getNumber(){
    return _model.number;
  }
}
class CounterRepository{
  CounterModel _model = CounterModel(0);
  void setNumber(int c){
    _model.number = c;
  }
  int getNumber(){
    return _model.number;
  }
}

class CountUpUsecase{
  NumberRepository _repository = NumberRepository();
  void increment(){
    _repository.setNumber(_repository.getNumber()+1);
  }
  int get nowNumber => _repository.getNumber();
}

class TimerService{
  void Function(int) callback;
  late Timer _timer;
  CounterRepository _repository = CounterRepository();
  TimerService(this.callback);

  void _tick(Timer timer) {
    _repository.setNumber(_repository.getNumber()+1);
    callback(_repository.getNumber());
  }
  void startTimer(){
    _timer = Timer.periodic(Duration(seconds: 1), _tick);
  }
  void timerCancel(){
    _timer.cancel();
  }
  int get nowNumber => _repository.getNumber();
}

class ViewModel{
  int timerNumber = 0;
  int counterNumber = 0;
  ViewModel(this.timerNumber, this.counterNumber);
}

class Controller{
  late void Function(ViewModel) _callback;
  CountUpUsecase usecase = CountUpUsecase();
  late TimerService service;

  void _tick(int counter){
    _callback(ViewModel(service.nowNumber, usecase.nowNumber));
  }
  Controller(void Function(ViewModel) callback){
    _callback = callback;
    service = TimerService(_tick);
  }
  void incrementCounter(){
    usecase.increment();
    _callback(ViewModel(service.nowNumber, usecase.nowNumber));
  }
  void startTimer(){
    service.startTimer();
  }
}


class MyHomePageView extends StatefulWidget {
  const MyHomePageView({super.key, required this.title});
  final String title;
  @override
  State<MyHomePageView> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePageView> {
  ViewModel state = ViewModel(0,0);
  late Controller controller;
  _MyHomePageState(){
    controller = Controller((ViewModel viewModel) {
      setState(() {
        state = viewModel;
      });
    });
    controller.startTimer();
  }

  void event() {
    controller.incrementCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${state.counterNumber}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'ticker counter',
            ),
            Text(
              '${state.timerNumber}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: event,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
