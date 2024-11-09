import Foundation
import UserNotifications

class HabitManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var habit: Habit? {
        didSet {
            saveHabit()
        }
    }
    
    private var missedCount = 0

    override init() {
        super.init()
        loadHabit()
        UNUserNotificationCenter.current().delegate = self
    }

    // Saving data to UserDefault for future using
    func saveHabit() {
        if let habit = habit {
            if let encoded = try? JSONEncoder().encode(habit) {
                UserDefaults.standard.set(encoded, forKey: "habitData")
            }
        }
    }

    // Load the data from UserDefaults
    func loadHabit() {
        if let savedHabit = UserDefaults.standard.object(forKey: "habitData") as? Data {
            if let decoded = try? JSONDecoder().decode(Habit.self, from: savedHabit) {
                self.habit = decoded
            }
        }
    }

    // Mark  habit as completed and update streak
    func completeHabit() {
        if var habit = habit {
            habit.streak += 1
            habit.lastCompleted = Date()
            self.habit = habit
            missedCount = 0
        }
    }
    
    

   //usin only for testing purose
    func simulateHabitCompletion() {
        completeHabit()
        scheduleNotification()
    }

    // Scheduling notification based on reminder time
    func scheduleNotification() {
        guard let habit = habit else { return }

        let content = UNMutableNotificationContent()

        if habit.streak >= 2 {
            content.title = "Great job! Keep up the streak!"
            content.body = "You're on fire! Stay consistent and keep it up!"
        } else if missedCount >= 2 {
            content.title = "You're almost there!"
            content.body = "Don't give up on your habit!"
        } else {
            content.title = "Keep Going!"
            content.body = "Don't miss your habit today!"
        }

        content.sound = .default

        // Calculate the reminder time for today
        //took help from stackOverFlow for reminderDate calculation
        let calendar = Calendar.current
        let reminderDate = calendar.date(bySettingHour: calendar.component(.hour, from: habit.reminderTime),
                                         minute: calendar.component(.minute, from: habit.reminderTime),
                                         second: 0,
                                         of: Date())

        // scheduling the time for same day and addition of day after 24 hours
        if var reminderDate = reminderDate, reminderDate < Date() {
            reminderDate.addTimeInterval(24 * 60 * 60)
        }

        // Checking is the reminder date is valid before creating a trigger
        guard let validReminderDate = reminderDate else { return }


        // Create a trigger based on the calculated reminder time
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: validReminderDate), repeats: true)

        // Create and add the notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    // function for display the notificatino when user is in  foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    //notification handle and response when the user dismisses
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            completeHabit()
        } else {
            missedCount += 1
            if missedCount == 2 {
                scheduleNotification()
            }
        }
        completionHandler()
    }
}
