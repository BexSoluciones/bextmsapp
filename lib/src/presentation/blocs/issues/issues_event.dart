part of 'issues_bloc.dart';

abstract class IssuesEvent {
  const IssuesEvent();
}

class GetIssuesList extends IssuesEvent {
  GetIssuesList(
      {required this.currentStatus,
      required this.summaryId,
      required this.workId});
  final String currentStatus;
  final int? workId;
  final int? summaryId;
}

class SelectIssue extends IssuesEvent {
  const SelectIssue({required this.newSelectedIssue});
  final Reason newSelectedIssue;
}

class SearchIssue extends IssuesEvent {
  const SearchIssue({required this.issueToSearch});
  final String issueToSearch;
}

class RequestUserWorkId extends IssuesEvent {
  const RequestUserWorkId({required this.userWorkId});
  final String userWorkId;
}

class ChangeObservations extends IssuesEvent {
  const ChangeObservations({required this.observations});
  final TextEditingController observations;
}

class ChangeFirm extends IssuesEvent {
  const ChangeFirm({required this.firm});
  final String firm;
}

class ChangePhotos extends IssuesEvent {
  const ChangePhotos({required this.photos});
  final String photos;
}

class RequestSummaryId extends IssuesEvent {
  const RequestSummaryId({required this.summaryId});
  final String summaryId;
}

class GetUserId extends IssuesEvent {
  const GetUserId({required this.userId});
  final String userId;
}
