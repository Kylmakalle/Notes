import Foundation


class FileNotebook {
    static let DATA_FILENAME = "notes.json"
    
    private(set) var notes: [String: Note]
    
    init() {
        self.notes = [String: Note]()
    }
    
    var dataPath: URL {
        var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        path.appendPathComponent(FileNotebook.DATA_FILENAME)
        return path
    }
    
    public func add(_ note: Note) {
        guard self.notes[note.uid] == nil else {
            // В задаче не сказано что делать в случае
            // повторения id, поэтому пока просто игнорируем
            return
        }
        
        self.notes[note.uid] = note
    }
    
    public func remove(with uid: String) {
        self.notes[uid] = nil
    }
    
    public func saveToFile() {
        do {
            let data = try JSONSerialization.data(
                withJSONObject: self.notes.values.map { $0.json },
                options: []
            )
            FileManager.default.createFile(atPath: self.dataPath.path, contents: data, attributes: nil)
        } catch {
            // В задаче не сказано каким образом должна
            // обрабатываться ошибка сериализации или записи в файл
        }
    }
    
    public func loadFromFile() {
        // Каким образом обрабатывать ошибки в задаче не обозначено
        
        let data: Data
        do {
            data = try Data(contentsOf: self.dataPath)
        } catch {
            return
        }
        
        let jsonData: Any
        do {
            try jsonData = JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            return
        }
        
        guard let jsonArray = jsonData as? [Dictionary<String, Any>] else {
            return
        }
        
        for noteData in jsonArray {
            let note = Note.parse(json: noteData)
            if note != nil {
                self.add(note!)
            }
        }
        
    }
}
