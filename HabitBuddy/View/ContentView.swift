import SwiftUI

struct ContentView: View {
    @ObservedObject var habitManager = HabitManager()
    @State private var newHabitName: String = ""
    @State private var reminderTime: Date = Date()
    @State private var showErrorMessage: Bool = false
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Habit Form
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Add New Habit")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        
                        
                        ZStack(alignment: .leading) {
                            if newHabitName.isEmpty {
                                Text("Enter Your Habit Here")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                            }
                            
                            TextField("", text: $newHabitName)
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                                .focused($isInputActive)
                                .submitLabel(.done)
                                .onSubmit {
                                    isInputActive = false
                                }
                        }
                        
                        VStack {
                            HStack {
                                Text("Set Reminder Time")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .frame(height: 120)
                                    .cornerRadius(15)
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)))
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        
                        // Error message for empty habit name
                        if showErrorMessage {
                            Text("Please enter a habit name!")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.bottom, 10)
                        }
                        
                        // Add Habit Button
                        Button(action: {
                            if newHabitName.isEmpty {
                                showErrorMessage = true
                            } else {
                                let habit = Habit(name: newHabitName, reminderTime: reminderTime, fixedReminderTime: reminderTime, streak: 0)
                                habitManager.habit = habit
                                habitManager.scheduleNotification()
                                newHabitName = ""
                                showErrorMessage = false
                            }
                        }) {
                            Text("Add Habit")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                        }
                        .disabled(newHabitName.isEmpty)
                    }
                    .padding()
                    .padding(.horizontal)
                    
                    // Habit Details
                    if let habit = habitManager.habit {
                        VStack(spacing: 20) {
                            Text(habit.name)
                                .font(.title)
                                .bold()
                                .padding(.bottom, 10)
                            
                            Text("Reminder set for: \(habit.fixedReminderTime, formatter: DateFormatter.shortTimeFormatter())")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            
                            ZStack {
                                
                                Circle()
                                    .strokeBorder(Color.gray.opacity(0.5), lineWidth: 5)
                                    .frame(width: 120, height: 120)
                                
                                
                                Circle()
                                    .fill(habit.streak > 0 ? Color.green : Color.red)
                                    .frame(width: 100, height: 100)
                                
                                
                                Text("\(habit.streak)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.bottom, 20)
                            
                            
                            let isCompletedToday = Calendar.current.isDateInToday(habit.lastCompleted ?? Date.distantPast)
                            Text(isCompletedToday ? "Status: Completed Today 🎉" : "Status: Uncompleted for Today 😔")
                                .font(.headline)
                                .foregroundColor(isCompletedToday ? .green : .red)
                                .padding(.bottom, 10)
                            
                            
                            Button(action: {
                                habitManager.completeHabit()
                            }) {
                                Text(isCompletedToday ? "Habit Completed" : "Mark as Completed")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(isCompletedToday ? Color.gray : Color.green)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                            }
                            .disabled(isCompletedToday)
                        }
                        .padding()
                        .padding(.horizontal)
                    }
                    
                    //                    FOR TESTING PURPOSE
                    //                    VStack(spacing: 10) {
                    //                        Button("Test Congratulatory Notification") {
                    //                            habitManager.simulateHabitCompletion()
                    //                        }
                    //                        .foregroundColor(.white)
                    //                        .padding()
                    //                        .background(Color.blue)
                    //                        .cornerRadius(10)
                    //                    }
                    
                    
                    Spacer()
                }
            }
            .navigationTitle("Habit Buddy")
            .gesture(
                TapGesture()
                    .onEnded {
                        //keyboard hat jayega when tapped anywhere on screen
                        UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?
                            .windows
                            .filter { $0.isKeyWindow }
                            .first?
                            .endEditing(true)
                    }
            )
            .padding(.bottom, 16)
        }
    }
}

extension DateFormatter {
    static func shortTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
