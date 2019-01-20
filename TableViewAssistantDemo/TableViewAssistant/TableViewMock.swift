//
//  TableViewSpy.swift
//  TableViewAssistantDemoTests
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import XCTest
@testable import TableViewAssistantDemo

class TableViewMock: UpdatableTableView {

    private var callIndex = 0

    var performBatchUpdatesCalled = false
    var performBatchUpdatesCalledIndex: Int!
    var performBatchUpdatesParams: [(updates: (() -> Void)?, completion: ((Bool) -> Void)?)] = []
    func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        performBatchUpdatesCalled = true
        performBatchUpdatesParams.append((updates: updates, completion: completion))
        defer { callIndex += 1 }
        performBatchUpdatesCalledIndex = callIndex
    }

    var beginUpdatesCalled = false
    var beginUpdatesCalledIndex: Int!
    func beginUpdates() {
        beginUpdatesCalled = true
        defer { callIndex += 1 }
        beginUpdatesCalledIndex = callIndex
    }

    var endUpdatesCalled = false
    var endUpdatesCalledIndex: Int!
    func endUpdates() {
        endUpdatesCalled = true
        defer { callIndex += 1 }
        endUpdatesCalledIndex = callIndex
    }

    var insertRowsCalled = false
    var insertRowsCalledIndex: Int!
    var insertRowsParams: (indexPaths: [IndexPath], animation: UITableView.RowAnimation)?
    func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertRowsCalled = true
        insertRowsParams = (indexPaths: indexPaths, animation: animation)
        defer { callIndex += 1 }
        insertRowsCalledIndex = callIndex
    }

    var deleteRowsCalled = false
    var deleteRowsCalledIndex: Int!
    var deleteRowsParams: (indexPaths: [IndexPath], animation: UITableView.RowAnimation)?
    func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        deleteRowsCalled = true
        deleteRowsParams = (indexPaths: indexPaths, animation: animation)
        defer { callIndex += 1 }
        deleteRowsCalledIndex = callIndex
    }

    var reloadRowsCalled = false
    var reloadRowsCalledIndex: Int!
    var reloadRowsParams: (indexPaths: [IndexPath], animation: UITableView.RowAnimation)?
    func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadRowsCalled = true
        reloadRowsParams = (indexPaths: indexPaths, animation: animation)
        defer { callIndex += 1 }
        reloadRowsCalledIndex = callIndex
    }

    var moveRowCalled = false
    var moveRowCalledIndex: Int!
    var moveRowParams: (indexPath: IndexPath, newIndexPath: IndexPath)?
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        moveRowCalled = true
        moveRowParams = (indexPath: indexPath, newIndexPath: newIndexPath)
        defer { callIndex += 1 }
        moveRowCalledIndex = callIndex
    }
}

extension TableViewMock {
    func collectBatchUpdateCallsIfNeeded() {
        for performBatchUpdatesParam in performBatchUpdatesParams {
            performBatchUpdatesParam.updates?()
        }
    }
}

// MARK: Self validation
extension TableViewMock {

    func reset() {
        callIndex = 0

        performBatchUpdatesCalled = false
        performBatchUpdatesCalledIndex = nil
        performBatchUpdatesParams = []

        beginUpdatesCalled = false
        beginUpdatesCalledIndex = nil

        endUpdatesCalled = false
        endUpdatesCalledIndex = nil

        insertRowsCalled = false
        insertRowsCalledIndex = nil
        insertRowsParams = nil

        deleteRowsCalled = false
        deleteRowsCalledIndex = nil
        deleteRowsParams = nil

        reloadRowsCalled = false
        reloadRowsCalledIndex = nil
        reloadRowsParams = nil

        moveRowCalled = false
        moveRowCalledIndex = nil
        moveRowParams = nil
    }

    func validateNoUpdatesMade() {
        validatePerformBatchUpdatesNotCalled()
        validateInsertRowsNotCalled()
        validateDeleteRowsNotCalled()
        validateReloadRowsNotCalled()
        validateMoveRowNotCalled()
    }

    func validatePerformBatchUpdatesNotCalled() {
        if performBatchUpdatesCalled {
            XCTFail("Perform batch updates was called on table view")
        }
        if beginUpdatesCalled {
            XCTFail("Begin updates was called on table view")
        }
        if endUpdatesCalled {
            XCTFail("End updates was called on table view")
        }
    }

    func validateInsertRowsNotCalled() {
        if insertRowsCalled {
            XCTFail("Insert rows  was called on table view")
        }
    }
    
    func validateDeleteRowsNotCalled() {
        if deleteRowsCalled {
            XCTFail("Delete rows was called on table view")
        }
    }

    func validateReloadRowsNotCalled() {
        if reloadRowsCalled {
            XCTFail("Reload rows was called on table view")
        }
    }

    func validateMoveRowNotCalled() {
        if moveRowCalled {
            XCTFail("Move row was called on table view")
        }
    }
}
