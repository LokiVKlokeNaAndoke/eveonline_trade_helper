import 'package:eveonline_trade_helper/models/eve_system.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';

import '../../services/market_data.dart';
import 'compare_systems_state.dart';

@immutable
class CmpSystems {
  final EveSystem from;
  final EveSystem to;

  CmpSystems(this.from, this.to);
}

class CompareSystemsBloc extends HydratedBloc<CmpSystems, CompareSystemsState> {
  final MarketDataService _marketData;
  final Logger _logger;

  CompareSystemsBloc(this._marketData, this._logger)
      : super(CompareSystemsState.empty());

  @override
  Stream<CompareSystemsState> mapEventToState(CmpSystems event) async* {
    yield CompareSystemsState.loading();

    try {
      final fromTo = await Future.wait(
          [event.from, event.to].map(this._marketData.systemData));
      final fromData = fromTo[0];
      final toData = fromTo[1];
      yield CompareSystemsState.comparison(fromData.cmpSellSell(toData));
    } on Exception catch (e) {
      _logger.e(e.toString());
      yield CompareSystemsState.error(e.toString());
    }
  }

  @override
  CompareSystemsState fromJson(Map<String, dynamic> json) {
    return CompareSystemsState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(CompareSystemsState state) {
    return state.toJson();
  }
}
