//
//  ContentView.swift
//  HabitMaster
//
//  Created by Alireza Toghiani on 1/18/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showModal = false
    @State private var newHabitTitle = ""
    @State private var newHabitRepeatPeriod = 1
    @State private var newHabitNotificationTime = Date()
    
    // Example items array
    @Query private var habits: [Habit] = []
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(habits) { habit in
                    HStack {
                        // Checkbox
                        Image(systemName: habit.isDone ? "checkmark.square.fill" : "square")
                        
                        // Habit Details
                        VStack(alignment: .leading) {
                            Text(habit.title)
                                .bold()
                            Text("Every \(habit.repeatPeriod) day(s)").font(.subheadline)
                            Text("Notify at \(habit.notificationTime, style: .time)").font(.subheadline)
                        }
                    }
                    .onTapGesture {
                        toggleHabit(habit)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showModal = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showModal) {
                // Modal form view
                Form {
                    TextField("Title", text: $newHabitTitle)
                    Stepper("Repeat every \(newHabitRepeatPeriod) day(s)", value: $newHabitRepeatPeriod)
                    DatePicker("Notification Time", selection: $newHabitNotificationTime, displayedComponents: .hourAndMinute)
                    Button("Add Habit") {
                        addItem()
                        showModal = false
                    }
                }
            }
        } detail: {
            Text("Record a habit")
        }
        .onAppear(perform: updateHabitStatus)
    }
    
    private func updateHabitStatus() {
        for habit in habits {
            if let lastCompletionDate = habit.completionHistory.last {
                if Calendar.current.date(byAdding: .day, value: habit.repeatPeriod, to: lastCompletionDate)! < Date() {
                    habit.isDone = false
                }
            }
        }
    }
    
    private func toggleHabit(_ habit: Habit) {
        withAnimation {
            if habit.isDone {
                // If marking as not done, remove the last date from history
                habit.completionHistory.removeLast()
                habit.isDone = false
            } else {
                // If marking as done, add the current date to history
                habit.completionHistory.append(Date())
                habit.isDone = true
            }
            
            // Automatically updating isDone based on repeat period
            if let lastCompletionDate = habit.completionHistory.last {
                if Calendar.current.date(byAdding: .day, value: habit.repeatPeriod, to: lastCompletionDate)! < Date() {
                    habit.isDone = false
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newHabit = Habit(title: newHabitTitle, repeatPeriod: newHabitRepeatPeriod, notificationTime: newHabitNotificationTime, isDone: false)
            modelContext.insert(newHabit)
            // Reset form fields and close modal
            newHabitTitle = ""
            newHabitRepeatPeriod = 1
            newHabitNotificationTime = Date()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { habits[$0] }.forEach(modelContext.delete)
        }
    }
    
    //    private func loadHabits() {
    //        // Fetch habits from the model context
    //        // This step might be redundant if @Query is set up correctly
    //        do {
    //            habits = try modelContext.fetch(Habit.all)
    //        } catch {
    //            print("Error fetching habits: \(error)")
    //        }
    //    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
