//
//  TodosApp.swift
//  Todos
//
//  Created by Taisei Sakamoto on 2022/05/06.
//

import SwiftUI
import ComposableArchitecture

@main
struct TodosApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppState(),
                    reducer: appReducer,
                    environment: AppEnvironment(
                        mainQueue: .main,
                        uuid: UUID.init)
                )
            )
        }
    }
}
