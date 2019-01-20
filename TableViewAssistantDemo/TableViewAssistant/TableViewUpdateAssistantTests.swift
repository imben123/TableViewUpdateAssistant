//
//  TableViewUpdateAssistantTests.swift
//  TableViewAssistantDemoTests
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import XCTest
@testable import TableViewAssistantDemo

final class TableViewUpdateAssistantTests: XCTestCase {

    private typealias Model = DummyModel

    private let obj1 = Model()
    private let obj2 = Model()
    private let obj3 = Model()
    private let obj4 = Model()

    private var tableViewMock: TableViewMock!
    private var sut: TableViewUpdateAssistant<Model>!

    override func setUp() {
        super.setUp()
        tableViewMock = TableViewMock()
        sut = TableViewUpdateAssistant(tableView: tableViewMock)
    }

    func test_doesNothingWhenNoUpdatesNeeded() {
        sut.applyUpdatesToTableView(with: [[]])
        tableViewMock.validateNoUpdatesMade()
    }

    func test_performBatchUpdatesCalledWhenThereAreChanges() {
        sut.applyUpdatesToTableView(with: [[Model()]])
        if #available(iOS 11.0, *) {
            XCTAssert(tableViewMock.performBatchUpdatesCalled)
        } else {
            // Fallback on earlier versions
            XCTAssert(tableViewMock.beginUpdatesCalled)
            XCTAssert(tableViewMock.endUpdatesCalled)
            XCTAssertLessThan(tableViewMock.beginUpdatesCalledIndex,
                              tableViewMock.endUpdatesCalledIndex)
        }
    }

    func test_performsDeletes() {
        // Given
        let sut = TableViewUpdateAssistant(tableView: tableViewMock, originalModel: [[Model()]])

        // When
        sut.applyUpdatesToTableView(with: [[]])
        tableViewMock.collectBatchUpdateCallsIfNeeded()

        // Then
        XCTAssert(tableViewMock.deleteRowsCalled)
        tableViewMock.validateInsertRowsNotCalled()
        tableViewMock.validateMoveRowNotCalled()
        tableViewMock.validateReloadRowsNotCalled()
        XCTAssertEqual(tableViewMock.deleteRowsParams?.indexPaths,
                       [IndexPath(row: 0, section: 0)])

        // Pre iOS 11 fallback
        assertCallIndexBetweenBeginAndEndUpdates(tableViewMock.deleteRowsCalledIndex)
    }

    func test_performsInserts() {
        // When
        sut.applyUpdatesToTableView(with: [[Model()]])
        tableViewMock.collectBatchUpdateCallsIfNeeded()

        // Then
        XCTAssert(tableViewMock.insertRowsCalled)
        tableViewMock.validateDeleteRowsNotCalled()
        tableViewMock.validateMoveRowNotCalled()
        tableViewMock.validateReloadRowsNotCalled()
        XCTAssertEqual(tableViewMock.insertRowsParams?.indexPaths,
                       [IndexPath(row: 0, section: 0)])

        // Pre iOS 11 fallback
        assertCallIndexBetweenBeginAndEndUpdates(tableViewMock.insertRowsCalledIndex)
    }

    func test_performsMoves() {
        // Given
        let sut = TableViewUpdateAssistant(tableView: tableViewMock, originalModel: [[obj1, obj2, obj3]])

        // When
        sut.applyUpdatesToTableView(with: [[obj2, obj1, obj3]])
        tableViewMock.collectBatchUpdateCallsIfNeeded()

        // Then
        XCTAssert(tableViewMock.moveRowCalled)
        tableViewMock.validateDeleteRowsNotCalled()
        tableViewMock.validateInsertRowsNotCalled()
        tableViewMock.validateReloadRowsNotCalled()
        XCTAssertEqual(tableViewMock.moveRowParams?.indexPath,
                       IndexPath(item: 0, section: 0))
        XCTAssertEqual(tableViewMock.moveRowParams?.newIndexPath,
                       IndexPath(item: 1, section: 0))

        // Pre iOS 11 fallback
        assertCallIndexBetweenBeginAndEndUpdates(tableViewMock.moveRowCalledIndex)
    }

    func test_performsUpdates() {

        // Given
        sut.applyUpdatesToTableView(with: [[obj1, obj2, obj3]])
        tableViewMock.reset()

        // When
        obj2.changeContent()
        sut.applyUpdatesToTableView(with: [[obj1, obj2, obj3]])
        tableViewMock.collectBatchUpdateCallsIfNeeded()

        // Then
        XCTAssert(tableViewMock.reloadRowsCalled)
        tableViewMock.validateDeleteRowsNotCalled()
        tableViewMock.validateMoveRowNotCalled()
        tableViewMock.validateInsertRowsNotCalled()
        XCTAssertEqual(tableViewMock.reloadRowsParams?.indexPaths,
                       [IndexPath(row: 1, section: 0)])

        // Pre iOS 11 fallback
        assertCallIndexBetweenBeginAndEndUpdates(tableViewMock.reloadRowsCalledIndex)
    }

    func test_updatesArePerformedAfterInsertsDeletesAndMoves() {

        // Given
        sut.applyUpdatesToTableView(with: [[obj1, obj2, obj3]])
        tableViewMock.reset()

        // When
        obj2.changeContent()
        sut.applyUpdatesToTableView(with: [[obj2, obj3]])
        tableViewMock.collectBatchUpdateCallsIfNeeded()

        // Then
        XCTAssertEqual(tableViewMock.reloadRowsParams?.indexPaths,
                       [IndexPath(row: 0, section: 0)])
    }

    func test_updatesAreAppliedInOwnPerformBatchBlock() {

        // Given
        sut.applyUpdatesToTableView(with: [[obj1, obj2, obj3]])
        tableViewMock.reset()

        // When
        obj2.changeContent()
        sut.applyUpdatesToTableView(with: [[obj2, obj3]])

        // Then
        XCTAssertEqual(tableViewMock.performBatchUpdatesParams.count, 2)

        // And When
        tableViewMock.performBatchUpdatesParams.last?.updates?()

        // Then
        tableViewMock.validateDeleteRowsNotCalled()
        tableViewMock.validateMoveRowNotCalled()
        tableViewMock.validateInsertRowsNotCalled()
        XCTAssertEqual(tableViewMock.reloadRowsParams?.indexPaths,
                       [IndexPath(row: 0, section: 0)])
    }

    func test_deletesAppliedBeforeInserts() {
        // Given
        let sut = TableViewUpdateAssistant(tableView: tableViewMock, originalModel: [[obj1, obj2, obj3]])

        // When
        sut.applyUpdatesToTableView(with: [[obj1, obj2, obj4]])
        tableViewMock.collectBatchUpdateCallsIfNeeded()

        // Then
        XCTAssertLessThan(tableViewMock.deleteRowsCalledIndex,
                          tableViewMock.insertRowsCalledIndex)
    }

    func test_movesAppliedLast() {
        // Given
        let sut = TableViewUpdateAssistant(tableView: tableViewMock, originalModel: [[obj1, obj2, obj3]])

        // When
        sut.applyUpdatesToTableView(with: [[obj2, obj1, obj4]])
        tableViewMock.collectBatchUpdateCallsIfNeeded()

        // Then
        XCTAssertLessThan(tableViewMock.deleteRowsCalledIndex,
                          tableViewMock.moveRowCalledIndex)
        XCTAssertLessThan(tableViewMock.insertRowsCalledIndex,
                          tableViewMock.moveRowCalledIndex)
    }

    func test_secondUpdateIsBasedOnUpdatedData() {
        // Given
        sut.applyUpdatesToTableView(with: [[Model()]])
        tableViewMock.reset()

        // When
        sut.applyUpdatesToTableView(with: [[]])
        tableViewMock.collectBatchUpdateCallsIfNeeded()

        // Then
        XCTAssert(tableViewMock.deleteRowsCalled)
        tableViewMock.validateInsertRowsNotCalled()
        tableViewMock.validateMoveRowNotCalled()
        XCTAssertEqual(tableViewMock.deleteRowsParams?.indexPaths,
                       [IndexPath(row: 0, section: 0)])
    }

    // MARK: Helpers

    private func assertCallIndexBetweenBeginAndEndUpdates(_ callIndex: Int) {
        guard #available(iOS 11.0, *) else {
            XCTAssertLessThan(tableViewMock.beginUpdatesCalledIndex,
                              callIndex)
            XCTAssertLessThan(callIndex,
                              tableViewMock.endUpdatesCalledIndex)
            return
        }
    }
}
