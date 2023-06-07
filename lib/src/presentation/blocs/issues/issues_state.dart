part of 'issues_bloc.dart';

class IssuesState {
  IssuesState(
      {this.issuesList,
      this.selectedIssue,
      this.immutableIssuesList,
      this.clientWorkId,
      this.observations,
      this.currentStatus,
      this.userId,
      this.status,
      this.nommotvis,
      this.codmotvis,
      this.latitude,
      this.longitude,
      this.observation,
      this.workId,
      this.firm,
      this.images,
      this.selectedSummaryId});

  final List<Reason>? issuesList;
  final List<Reason>? immutableIssuesList;
  final TextEditingController? observations;
  final String? currentStatus;
  final String? clientWorkId;
  final Reason? selectedIssue;
  final int? userId;
  final String? status;
  final String? nommotvis;
  final String? codmotvis;
  final String? latitude;
  final String? longitude;
  final String? observation;
  final int? selectedSummaryId;
  final int? workId;
  final dynamic firm;
  final dynamic images;

  IssuesState copyWith({
    List<Reason>? issuesList,
    List<Reason>? immutableIssuesList,
    Reason? selectedIssue,
    String? currentStatus,
    TextEditingController? observations,
    String? clientWorkId,
    int? userId,
    String? status,
    String? nommotvis,
    String? codmotvis,
    String? latitude,
    String? longitude,
    String? observation,
    int? selectedSummaryId,
    int? workId,
    dynamic firm,
    dynamic images,
  }) =>
      IssuesState(
        selectedSummaryId: selectedSummaryId ?? this.selectedSummaryId,
        currentStatus: currentStatus ?? this.currentStatus,
        issuesList: issuesList ?? this.issuesList,
        selectedIssue: selectedIssue ?? this.selectedIssue,
        immutableIssuesList: immutableIssuesList ?? this.immutableIssuesList,
        clientWorkId: clientWorkId ?? this.clientWorkId,
        observations: observations ?? this.observations,
        userId: userId ?? this.userId,
        status: status ?? this.status,
        nommotvis: nommotvis ?? this.nommotvis,
        codmotvis: codmotvis ?? this.codmotvis,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        observation: observation ?? this.observation,
        workId: workId ?? this.workId,
        firm: firm ?? this.firm,
        images: images ?? this.images,
      );
}
