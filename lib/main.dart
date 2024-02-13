import 'dart:async';
import 'package:flutter/material.dart';

// モデルクラス
class NumberModel {
  int number;
  NumberModel(this.number);
}

class CounterModel {
  int number;
  CounterModel(this.number);
}

// リポジトリクラス
class NumberRepository {
  NumberModel _model = NumberModel(0);

  void setNumber(int number) {
    _model.number = number;
  }

  int getNumber() {
    return _model.number;
  }
}

class CounterRepository {
  CounterModel _model = CounterModel(0);

  void setNumber(int number) {
    _model.number = number;
  }

  int getNumber() {
    return _model.number;
  }
}

// ユースケースクラス
class CounterUseCase {
  NumberRepository _numberRepository = NumberRepository();

  void increment() {
    _numberRepository.setNumber(_numberRepository.getNumber() + 1);
  }

  int getCurrentNumber() {
    return _numberRepository.getNumber();
  }
}

// サービスクラス
class TimerService {
  void Function(int) callback;
  late Timer _timer;
  CounterRepository _counterRepository = CounterRepository();

  TimerService(this.callback);

  void _tick(Timer timer) {
    _counterRepository.setNumber(_counterRepository.getNumber() + 1);
    callback(_counterRepository.getNumber());
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), _tick);
  }

  void timerCancel() {
    _timer.cancel();
  }

  int getCurrentNumber() {
    return _counterRepository.getNumber();
  }
}

// ViewModelクラス
class ViewModel {
  int timerNumber;
  int counterNumber;
  ViewModel(this.timerNumber, this.counterNumber);
}

// Controllerクラス
class Controller {
  late void Function(ViewModel) _callback;
  CounterUseCase _counterUseCase = CounterUseCase();
  late TimerService _timerService;

  void _tick(int counter) {
    _callback(ViewModel(_timerService.getCurrentNumber(), _counterUseCase.getCurrentNumber()));
  }

  Controller(void Function(ViewModel) callback) {
    _callback = callback;
    _timerService = TimerService(_tick);
  }

  void incrementCounter() {
    _counterUseCase.increment();
    _callback(ViewModel(_timerService.getCurrentNumber(), _counterUseCase.getCurrentNumber()));
  }

  void startTimer() {
    _timerService.startTimer();
  }

  void dispose() {
    _timerService.timerCancel();
  }
}

// メインのアプリケーション
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePageView(title: 'Counter Example'),
    );
  }
}

class MyHomePageView extends StatefulWidget {
  final String title;

  const MyHomePageView({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePageView> createState() => _MyHomePageViewState();
}

class _MyHomePageViewState extends State<MyHomePageView> {
  ViewModel _viewModel = ViewModel(0, 0);
  late Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = Controller((ViewModel viewModel) {
      setState(() {
        _viewModel = viewModel;
      });
    });
    _controller.startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    _controller.incrementCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Counter: ${_viewModel.counterNumber}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Timer: ${_viewModel.timerNumber}',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}