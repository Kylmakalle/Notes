//
//  FileNoteBookTest.swift
//  NotesTests

import XCTest
@testable import Notes

class FileNoteBookTest: XCTestCase {
    
    private let uid = "y7834equwghdjknsa"
    private let title = "Test Title"
    private let content = "Test Content\n\nTest Content"
    private let importance = Note.Importance.normal
    private var testFileNotebook: FileNotebook!
    
    override func setUp() {
        super.setUp()
        testFileNotebook = FileNotebook()
    }
    
    override func tearDown() {
        testFileNotebook = nil
        super.tearDown()
    }
    
    func testFileNotebookIsClass() {
        guard let fileNotebook = testFileNotebook, let displayStyle = Mirror(reflecting: fileNotebook).displayStyle else {
            XCTFail()
            return
        }
        XCTAssertEqual(displayStyle, .class)
    }
    
    func testWhenNoteIsEmpty() {
        XCTAssertTrue(testFileNotebook.notes.isEmpty)
    }
    
    func testAddNoteAndNoteSaveFile() {
        let note = Note(title: title, content: content, importance: importance)
        testFileNotebook.add(note)
        
        let notes = testFileNotebook.notes
        
        XCTAssertEqual(notes.count, 1)
        
        let checkedNote = getNote(by: note.uid, from: notes)
        
        XCTAssertNotNil(checkedNote)
        
    }
    
    private func getNote(by uid: String, from notes:Any) -> Note? {
        if let notes = notes as? [String: Note] {
            return notes[uid]
        }
        
        if let notes = notes as? [Note] {
            return notes.filter { $0.uid == uid }.first
        }
        
        return nil
    }
}
