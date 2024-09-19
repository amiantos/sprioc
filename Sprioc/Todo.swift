//
//  Todo.swift
//  Sprioc
//
//  Created by Brad Root on 9/18/24.
//

import Foundation
import SwiftData

@Model
final class Todo {
    var name: String
    var dueDate: Date?
    var timestamp: Date
    var complete: Bool = false

    init(name: String) {
        self.name = name
        self.timestamp = Date.now
    }
}

extension Bool: @retroactive Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        // the only true inequality is false < true
        !lhs && rhs
    }
}
