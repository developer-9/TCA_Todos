//
//  Todo.swift
//  Todos
//
//  Created by Taisei Sakamoto on 2022/05/06.
//

import Foundation
import ComposableArchitecture


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
