

import Foundation

struct Habit: Codable {
    var name: String
    var reminderTime: Date
    var fixedReminderTime: Date
    var streak: Int
    var lastCompleted: Date?
}
