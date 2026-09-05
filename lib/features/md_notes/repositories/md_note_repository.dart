
import '../models/md_note.dart';

abstract class MdNoteRepository {
  Future<List<MdNote>> fetchNotes();
  Future<MdNote> fetchNote(String id);
  Future<MdNote> createNote(CreateMdNoteInput input);
  Future<MdNote> updateNote(String id, UpdateMdNoteInput input);
  Future<void> deleteNote(String id);
}
