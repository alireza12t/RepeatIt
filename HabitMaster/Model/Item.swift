//
//  Item.swift
//  HabitMaster
//
//  Created by Alireza Toghiani on 1/18/24.
//

import Foundation
import SwiftData

@Model
final class Habit: Identifiable {
    var id = UUID()
    var title: String
    var repeatPeriod: Int
    var notificationTime: Date
    var isDone = false
    var completionHistory: [Date] = [] // Add this line
    // TODO: Add creation date

    init(id: UUID = UUID(), title: String, repeatPeriod: Int, notificationTime: Date, isDone: Bool) {
        self.id = id
        self.title = title
        self.repeatPeriod = repeatPeriod
        self.notificationTime = notificationTime
        self.isDone = isDone
    }
}
