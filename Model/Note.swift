import UIKit

struct Note {
    enum Importance: Int {
        case low = -1
        case normal = 0
        case high = 1
    }
    
    let uid: String
    let title: String
    let content: String
    let importance: Importance
    let color: UIColor
    let selfDestructionDate: Date?
    
    init(uid: String = UUID().uuidString,
         title: String,
         content: String,
         importance: Importance,
         color: UIColor = UIColor.white,
         selfDestructionDate: Date? = nil) {
        self.uid = uid
        self.title = title
        self.content = content
        self.color = color
        self.importance = importance
        self.selfDestructionDate = selfDestructionDate
    }
}
