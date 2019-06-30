//
//  NotesTests.swift
//  NotesTests
//
//  Created by Sergey on 30/06/2019.
//  Copyright © 2019 Sergey Akentev. All rights reserved.
//

import XCTest
@testable import Notes

class NoteTests: XCTestCase {
    
    private let uid = "y7834equwghdjknsa"
    private let title = "Test Title"
    private let content = "Test Content\n\nTest Content"
    private let importance = Note.Importance.normal
    private var testNote: Note!
    
    override func setUp() {
        super.setUp()
        testNote = Note(title: title, content: content, importance: importance)
    }
    
    override func tearDown() {
        testNote = nil
        super.tearDown()
    }
    
    
    func testNoteIsStruct() {
        guard let note = testNote, let displayStyle = Mirror(reflecting: note).displayStyle else {
            XCTFail()
            return
        }
        XCTAssertEqual(displayStyle, .struct)
    }
    
    func testNoteInitWithSetUid() {
        let note = Note(uid: uid, title: title, content: content, importance: importance)
        
        XCTAssertEqual(uid, note.uid)
    }
    
    func testNoteInitWithGeneratesUid() {
        let note = Note(title: title, content: content, importance: importance)
        
        XCTAssertNotEqual(testNote.uid, note.uid)
    }
    
    func testNoteInitTitle() {
        XCTAssertEqual(testNote.title, title)
    }
    
    func testNoteInitContent() {
        XCTAssertEqual(testNote.content, content)
    }
    
    func testNoteInitDefaulColor() {
        XCTAssertEqual(testNote.color, UIColor.white)
    }
    
    func testNoteInitWithCustomColor() {
        let color = UIColor.red
        let note = Note(title: title, content: content, importance: importance, color: color)
        
        XCTAssertEqual(note.color, color)
    }
    
    func testNoteInitDefaultDate() {
        XCTAssertNil(testNote.selfDestructionDate)
    }
    
    func testNoteInitCustomDate() {
        let date = Date()
        let note = Note(title: title, content: content, importance: importance, selfDestructionDate: date)
        
        XCTAssertEqual(note.selfDestructionDate, date)
    }
    
}

