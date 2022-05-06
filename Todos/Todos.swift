//
//  Todos.swift
//  Todos
//
//  Created by Taisei Sakamoto on 2022/05/06.
//

import ComposableArchitecture
import SwiftUI

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

struct AppState: Equatable {
    var editMode: EditMode = .inactive
    var filter: Filter = .all
    var todos: IdentifiedArrayOf<Todo> = []
    
    var filteredTodos: IdentifiedArrayOf<Todo> {
        switch filter {
        case .all:
            return self.todos
        case .active:
            return self.todos.filter { !$0.isComplete }
        case .completed:
            return self.todos.filter(\.isComplete)
        }
    }
}
