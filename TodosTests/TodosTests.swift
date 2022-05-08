//
//  TodosTests.swift
//  TodosTests
//
//  Created by Taisei Sakamoto on 2022/05/06.
//

import XCTest
import ComposableArchitecture
@testable import Todos

class TodosTests: XCTestCase {
    
    let scheduler = DispatchQueue.test
    
    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing)
        )
        
        store.send(.addTodoButtonTapped) {
            $0.todos.insert(
                Mock.todo, at: 0
            )
        }
    }
    
    func testEditTodo() {
        let state = AppState(
            todos: [Mock.todo]
        )
        let store = TestStore(
            initialState: state,
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: UUID.incrementing
            )
        )
        
        store.send(
            .todo(id: state.todos[0].id, action: .textFieldChanged(.mock))
        ) {
            $0.todos[id: state.todos[0].id]?.description = .mock
        }
    }
            

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

extension UUID {
    static var incrementing: () -> UUID {
        var uuid = 0
        return {
            defer { uuid += 1 }
            return UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", uuid))")!
        }
    }
}

extension String {
    static let mock = "mock"
    static let uuid = "00000000-0000-0000-0000-000000000000"
}

enum Mock {
    static var todo = Todo(
        description: .mock,
        id: UUID(uuidString: .uuid)!,
        isComplete: false
    )
}
