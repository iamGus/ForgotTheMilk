//
//  ReminderCellViewModel.swift
//  ForgotTheMilk
//
//  Created by Angus Muller on 28/11/2017.
//  Copyright © 2017 Angus Muller. All rights reserved.
//

import Foundation

struct ReminderCellViewModel {
    let title: String
    let placeMark: String? // Note temp optional
}

extension ReminderCellViewModel {
    init(reminder: Reminder) {
        title = reminder.titleString
        placeMark = reminder.placeMarkString
    }
}
