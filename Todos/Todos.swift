//
//  Todos.swift
//  Todos
//
//  Created by Taisei Sakamoto on 2022/05/06.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Enum

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

// MARK: - State

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

// MARK: - Action

enum AppAction: Equatable {
    case addTodoButtonTapped
    case clearCompletedButtonTapped
    case delete(IndexSet)
    case editModeChanged(EditMode)
    case filterPicked(Filter)
    case move(IndexSet, Int)
    case sortCompletedTodos
    case todo(id: Todo.ID, action: TodoAction)
}

// MARK: - Environment

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
}

//MARK: - Reducer

let appReducer = Reducer<AppState, AppAction, AppEnvironment>
    .combine(
        todoReducer.forEach(
            state: \.todos,
            action: /AppAction.todo(id: action:),
            environment: { _ in TodoEnvironment() }
        ),
        
        Reducer { state, action, environment in
            switch action {
            case .addTodoButtonTapped:
                state.todos.insert(Todo(id: environment.uuid()), at: 0)
                return .none
                
            case .clearCompletedButtonTapped:
                state.todos.removeAll(where: \.isComplete)
                return .none
                
            case .delete(let indexSet):
                state.todos.remove(atOffsets: indexSet)
                return .none
                
            case .editModeChanged(let editMode):
                state.editMode = editMode
                return .none
                
            case .filterPicked(let filter):
                state.filter = filter
                return .none
                
            case .move(var source, var destination):
                if state.filter != .all {
                    source = IndexSet(
                        source
                            .map { state.filteredTodos[$0] }
                            .compactMap { state.todos.index(id: $0.id) }
                    )
                    destination = state.todos.index(id: state.filteredTodos[destination].id) ?? destination
                }
                state.todos.move(fromOffsets: source, toOffset: destination)
                
                return Effect(value: .sortCompletedTodos)
                    .delay(for: .milliseconds(100), scheduler: environment.mainQueue)
                    .eraseToEffect()
                
            case .sortCompletedTodos:
                state.todos.sort { $1.isComplete && !$0.isComplete }
                return .none
                
            case .todo(id: _, action: .checkBoxToggled):
                enum TodoCompletionId {}
                return Effect(value: .sortCompletedTodos)
                    .debounce(id: TodoEnvironment.self, for: 1, scheduler: environment.mainQueue.animation())
                
            case .todo:
                return .none
            }
        }
    )
    .debug()

// MARK: - View

struct AppView: View {
    let store: Store<AppState, AppAction>
    @ObservedObject var viewStore: ViewStore<ViewState, AppAction>
    
    struct ViewState: Equatable {
        let editMode: EditMode
        let filter: Filter
        let isClearCompletedButtonDisabled: Bool
        
        init(state: AppState) {
            self.editMode = state.editMode
            self.filter = state.filter
            self.isClearCompletedButtonDisabled = !state.todos.contains(where: \.isComplete)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Picker(
                    "Filter",
                    selection: viewStore.binding(get: \.filter, send: AppAction.filterPicked).animation()
                ) {
                    ForEach(Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    ForEachStore(
                        store.scope(state: \.filteredTodos, action: AppAction.todo(id: action:)),
                        content: TodoView.init(store:)
                    )
                    .onDelete { viewStore.send(.delete($0)) }
                    .onMove { viewStore.send(.move($0, $1)) }
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                    
                    Button("Clear Completed") {
                        viewStore.send(.clearCompletedButtonTapped, animation: .default)
                    }
                    .disabled(viewStore.isClearCompletedButtonDisabled)
                    
                    Button("Add Todo") {
                        viewStore.send(.addTodoButtonTapped, animation: .default)
                    }
                    .environment(
                        \.editMode,
                         viewStore.binding(get: \.editMode, send: AppAction.editModeChanged)
                    )
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
