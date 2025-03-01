import 'package:bloc/bloc.dart';
import 'package:elaichi/domain/models/event.dart';
import 'package:elaichi/domain/repositories/events_repository.dart';
import 'package:elaichi/domain/repositories/user_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required UserRepository userRepository,
    required EventRepository eventRepository,
  })  : _userRepository = userRepository,
        _eventRepository = eventRepository,
        super(const _Initial()) {
    getRollNumber();
    on<_WebMailLogOut>((event, emit) {
      emit(const ProfileState.loading());
      _userRepository.deleteWebMailDetails();
      emit(const ProfileState.webMailLoggedOut());
      emit(const ProfileState.initial());
    });
    on<_AppLogOut>((event, emit) async {
      emit(const ProfileState.loading());
      await _userRepository.appLogOut();
      emit(const ProfileState.appLoggedOut());
    });
  }

  final UserRepository _userRepository;
  final EventRepository _eventRepository;
  String? rollNumber;

  void getRollNumber() {
    rollNumber = _userRepository.rollNumber;
  }

  bool get isZimraAuthenticated {
    if (_userRepository.rollNumber != null) {
      return true;
    } else {
      return false;
    }
  }

  List<Event> getEvents() {
    return _eventRepository.events!;
  }

  Future<List<Event>?> refreshAndGetEvents() async {
    await _eventRepository.fetchEvents();
    return _eventRepository.events;
  }
}
