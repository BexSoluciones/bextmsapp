part of '../app_database.dart';

class NoteDao {
  final AppDatabase _appDatabase;

  NoteDao(this._appDatabase);

  List<Note> parseNotes(List<Map<String, dynamic>> noteList) {
    final notes = <Note>[];
    for (var noteMap in noteList) {
      final note = Note.fromJson(noteMap);
      notes.add(note);
    }
    return notes;
  }

  Future<List<Note>> getAllNotes() async {
    final db = await _appDatabase.streamDatabase;
    final noteList = await db!.query(tableNotes);
    final notes = parseNotes(noteList);
    return notes;
  }

  Future<Note?> findNote(String zoneId) async {
    final db = await _appDatabase.streamDatabase;
    final noteList =
    await db!.query(tableNotes, where: 'zone_id = ?', whereArgs: [zoneId]);
    final note = parseNotes(noteList);
    if(note.isEmpty){
      return null;
    }
    return note.first;
  }

  Future<int> insertNote(Note note) {
    return _appDatabase.insert(tableNotes, note.toJson());
  }

  Future<int> updateNote(Note note) {
    return _appDatabase.update(tableNotes, note.toJson(), 'id', note.id!);
  }

  Future<int> deleteNote(Note note){
    return _appDatabase.delete(tableNotes, 'id', note.id!);
  }

  Future<int> deleteAll(int noteId){
    return _appDatabase.delete(tableNotes, 'id', noteId);
  }

  Future<void> insertNotes(List<Note> notes) async {
    final db = await _appDatabase.streamDatabase;
    var batch = db!.batch();

    if (notes.isNotEmpty) {
      await Future.forEach(notes, (note) async {
        var d = await db.query(tableNotes, where: 'id = ?', whereArgs: [note.id]);
        var w = parseNotes(d);
        if (w.isEmpty) {
          batch.insert(tableNotes, note.toJson());
        } else {
          batch.update(tableNotes, note.toJson(), where: 'id = ?', whereArgs: [note.id]);
        }
      });
    }
    await batch.commit(noResult: true);
    return Future.value();
  }

  Future<void> emptyNotes() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableNotes, where: 'id > 0');
    return Future.value();
  }
}
