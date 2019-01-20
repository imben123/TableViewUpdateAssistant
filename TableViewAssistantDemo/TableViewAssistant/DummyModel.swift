//
//  DummyModel.swift
//  TableViewAssistantDemoTests
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import Foundation

class DummyModel {

    private static var value = 0
    private static func nextValue() -> Int {
        defer { value += 1 }
        return value

    }

    static func resetCounter() {
        value = 0
    }

    fileprivate(set) var value: Int = nextValue()

    func changeContent() {
        value += 1
    }
}

extension DummyModel: Equatable {
    static func == (lhs: DummyModel, rhs: DummyModel) -> Bool {
        return lhs.value == rhs.value
    }
}

extension DummyModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
