//
//  Todo.swift
//  Todos
//
//  Created by Taisei Sakamoto on 2022/05/06.
//

import Foundation
import ComposableArchitecture
import SwiftUI


//MARK: - State

struct Todo: Equatable, Identifiable {
    var description = ""
    let id: UUID
    var isComplete = false
}

// MARK: - Action

enum TodoAction: Equatable {
    case checkBoxToggled
    case textFieldChanged(String)
}

// MARK: - Environment

struct TodoEnvironment {}

// MARK: - Reducer

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { todo, action, _ in
    switch action {
    case .checkBoxToggled:
        todo.isComplete.toggle()
        return .none
    case .textFieldChanged(let description):
        todo.description = description
        return .none
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkBoxToggled) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)
                
                TextField("Untitled Todo", text: viewStore.binding(get: \.description, send: TodoAction.textFieldChanged))
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}
