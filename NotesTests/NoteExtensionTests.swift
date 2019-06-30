//
//  NoteExtensionTests.swift
//  NotesTests
//
//  Created by Sergey on 30/06/2019.
//  Copyright © 2019 Sergey Akentev. All rights reserved.
//

import XCTest
@testable import Notes

class ExtencionTest: XCTestCase {
    
    private let uid = "y7834equwghdjknsa"
    private let title = "Test Title"
    private let content = "Test Content\n\nTest Content"
    private let importance = Note.Importance.normal
    var testNote: Note!
    
    override func setUp() {
        super.setUp()
        testNote = Note(title: title, content: content, importance: importance)
    }
    
    override func tearDown() {
        testNote = nil
        super.tearDown()
    }
    
    func testParseEmptyDict() {
        let note = Note.parse(json: [:])
        XCTAssertNil(note)
    }
    
    func testWhenGetEmptyJson() {
        let json = testNote.json
        
        XCTAssertFalse(json.isEmpty)
    }
    
    func testWhenGetJsonWithWhiteColor() {
        let note = Note(title: title, content: content, importance: importance, color: UIColor.red)
        let json = note.json
        let jsonWithWhiteColor = testNote.json
        
        XCTAssertTrue(json.count > jsonWithWhiteColor.count)
    }
    
    func testWhenGetJsonWithOrdinaryImportance() {
        let note = Note(title: title, content: content, importance: .high)
        let json = note.json
        let jsonWithOrdianryImportance = testNote.json
        
        XCTAssertTrue(json.count > jsonWithOrdianryImportance.count)
    }
    
    func testWhenGetJsonWithotDate() {
        let note = Note(title: title, content: content, importance: .high, selfDestructionDate: Date())
        let json = note.json
        let jsonWithoutDate = testNote.json
        
        XCTAssertTrue(json.count > jsonWithoutDate.count)
    }
    
    func testGetJsonAndParseJsonIsNote() {
        let note = getNoteThroughJsonFrom(testNote)
        
        XCTAssertNotNil(note)
        
    }
    
    func testWhenGetJsonAndParseJsonIsEqual() {
        let note = getNoteThroughJsonFrom(testNote)
        
        guard let note1 = note else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(testNote.uid, note1.uid)
        XCTAssertEqual(testNote.title, note1.title)
        XCTAssertEqual(testNote.content, note1.content)
        XCTAssertEqual(testNote.importance, note1.importance)
        XCTAssertEqual(testNote.color, note1.color)
        
        XCTAssertNil(testNote.selfDestructionDate)
        XCTAssertNil(note1.selfDestructionDate)
    }
    
    func testWhenGetJsonAndParseJsonIsEqualFullNote() {
        let fullNote = Note(title: "Title", content: "Content", importance: .low, color: UIColor.green, selfDestructionDate: Date())
        let note = getNoteThroughJsonFrom(fullNote)
        
        guard let note1 = note else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(fullNote.uid, note1.uid)
        XCTAssertEqual(fullNote.title, note1.title)
        XCTAssertEqual(fullNote.content, note1.content)
        XCTAssertEqual(fullNote.importance, note1.importance)
        XCTAssertEqual(fullNote.color, note1.color)
        
        
        guard let fullDate = fullNote.selfDestructionDate, let date = note1.selfDestructionDate else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(fullDate.timeIntervalSinceReferenceDate, date.timeIntervalSinceReferenceDate, accuracy: 0.0001)
    }
    
    private func getNoteThroughJsonFrom(_ note: Note) -> Note? {
        return Note.parse(json: note.json)
    }
    
}


