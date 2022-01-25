import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keylol_flutter/models/sec_code.dart';

part 'login_password_event.dart';

part 'login_password_state.dart';

class LoginPasswordBloc extends Bloc<LoginPasswordEvent, LoginPasswordState> {
  final Dio client;

  LoginPasswordBloc({required this.client})
      : super(LoginPasswordState(status: LoginPasswordStatus.initial));
}
