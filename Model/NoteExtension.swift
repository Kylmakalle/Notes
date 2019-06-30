import Foundation
import UIKit

extension UIColor {
    static func fromHex(value: String) -> UIColor? {
        let regex = try? NSRegularExpression(
            pattern: "^#([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})",
            options: .caseInsensitive
        )
        
        guard regex != nil else { return nil }
        
        let match = regex!.firstMatch(
            in: value, options: [],
            range: NSRange(location: 0, length: value.count)
        )
        
        guard match != nil else { return nil }
        
        let red = Range(match!.range(at: 1), in: value)
        let green = Range(match!.range(at: 2), in: value)
        let blue = Range(match!.range(at: 3), in: value)
        
        guard red != nil && green != nil && blue != nil else { return nil }
        
        let r = UInt8(value[red!], radix: 16)
        let g = UInt8(value[green!], radix: 16)
        let b = UInt8(value[blue!], radix: 16)
        
        guard r != nil && g != nil && b != nil else { return nil }
        
        return UIColor(
            red: CGFloat(r!) / 255,
            green: CGFloat(g!) / 255,
            blue: CGFloat(b!) / 255,
            alpha: 1
        )
    }
    
    func hexString() -> String {
        // Для цвета заметки aplha-канал не имеет смысла, поэтому
        // игнорируем его (ожидается что alpha всегда будет 1.0)
        
        let ciColor = CIColor(color: self)
        let red = UInt(ciColor.red * 255 + 0.5)
        let green = UInt(ciColor.green * 255 + 0.5)
        let blue = UInt(ciColor.blue * 255 + 0.5)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    func isWhite() -> Bool {
        // Можно оптимизировать в случае необходимости,
        // пока сойдет и сравнение со строкой
        return self.hexString() == "#FFFFFF"
    }
}

extension Note {
    static func parse(json: [String: Any]) -> Note? {
        guard let uid = json["uid"] as? String else { return nil }
        guard let title = json["title"] as? String else { return nil }
        guard let content = json["content"] as? String else { return nil }
        
        var importance = Note.Importance.normal
        if let rawImportance = json["importance"] {
            guard let importanceInt = rawImportance as? Int else { return nil }
            guard let importanceValue = Note.Importance(rawValue: importanceInt) else { return nil }
            importance = importanceValue
        }
        
        var color = UIColor.white
        if let rawColor = json["color"] {
            guard let rawColor = rawColor as? String else { return nil }
            guard let colorValue = UIColor.fromHex(value: rawColor) else { return nil }
            color = colorValue
        }
        
        var date: Date?
        guard let dateString = json["selfDestructionDate"] as? String else { return nil }
        if dateString == "" {
            date = nil
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let dateValue = formatter.date(from: dateString) else { return nil }
            date = dateValue
        }
        
        return Note(
            uid: uid,
            title: title,
            content: content,
            importance: importance,
            color: color,
            selfDestructionDate: date
        )
    }
    
    var json: [String: Any] {
        var data: [String: Any] = [
            "uid": self.uid,
            "title": self.title,
            "content": self.content,
        ]
        
        if self.importance != Note.Importance.normal {
            data["importance"] = self.importance.rawValue
        }
        
        if !self.color.isWhite() {
            data["color"] = self.color.hexString()
        }
        
        if self.selfDestructionDate != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            data["selfDestructionDate"] = formatter.string(from: self.selfDestructionDate!)
        } else {
            // В задаче не сказано о том, что бы не записывать
            // дату в случае ее отсутствия, поэтому пишем пустую строку
            data["selfDestructionDate"] = ""
        }
        
        return data
    }
}
