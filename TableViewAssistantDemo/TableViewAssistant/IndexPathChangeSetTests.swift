//
//  IndexPathChangeSetTests.swift
//  TableViewAssistantDemoTests
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import XCTest
@testable import TableViewAssistantDemo

final class IndexPathChangeSetTests: XCTestCase {

    let inserts = [IndexPath(row: 0, section: 0)]
    let deletes = [IndexPath(row: 1, section: 0)]
    let updates = [IndexPath(row: 2, section: 0)]

    let moves = [IndexPathMove(fromIndexPath: IndexPath(row: 3, section: 0),
                               toIndexPath: IndexPath(row: 4, section: 0))]

    func test_init() {
        let sut = createBasicIndexPathChangeSet()
        XCTAssertEqual(sut.insertIndexPaths, inserts)
        XCTAssertEqual(sut.deleteIndexPaths, deletes)
        XCTAssertEqual(sut.updateIndexPaths, updates)
        XCTAssertEqual(sut.moveIndexPaths, moves)
    }

    func test_isEqualToMatchingIndexPaths() {
        let sut = createBasicIndexPathChangeSet()
        let other = createBasicIndexPathChangeSet()
        XCTAssertEqual(sut, other)
    }

    func test_isNotEqualToNonMatchingIndexPaths() {
        let sut = createBasicIndexPathChangeSet()
        let other = createAnotherBasicIndexPathChangeSet()
        XCTAssertNotEqual(sut, other)
    }

    func test_whenThereAreNoMoves_correctedUpdateIndexPathsAreTheSame() {
        let sut = IndexPathChangeSet(insertIndexPaths: [],
                                     deleteIndexPaths: [],
                                     updateIndexPaths: updates,
                                     moveIndexPaths: [])
        XCTAssertEqual(sut.correctedUpdateIndexPaths, sut.updateIndexPaths)
    }

    func test_correcectedUpdateIndexPaths_haveMovesApplied() {

        let updates = [IndexPath(row: 2, section: 1)]
        let moves = [IndexPathMove(fromIndexPath: IndexPath(row: 2, section: 1),
                                   toIndexPath: IndexPath(row: 3, section: 0))]

        let sut = IndexPathChangeSet(insertIndexPaths: [],
                                     deleteIndexPaths: [],
                                     updateIndexPaths: updates,
                                     moveIndexPaths: moves)

        let expected = [IndexPath(row: 3, section: 0)]
        XCTAssertEqual(sut.correctedUpdateIndexPaths, expected)
    }

    func test_hasUpdates() {
        var sut = IndexPathChangeSet()
        XCTAssertFalse(sut.hasUpdates)
        
        sut = IndexPathChangeSet(insertIndexPaths: [IndexPath(row: 0, section: 0)])
        XCTAssertTrue(sut.hasUpdates)

        sut = IndexPathChangeSet(deleteIndexPaths: [IndexPath(row: 0, section: 0)])
        XCTAssertTrue(sut.hasUpdates)

        sut = IndexPathChangeSet(updateIndexPaths: [IndexPath(row: 0, section: 0)])
        XCTAssertTrue(sut.hasUpdates)

        sut = IndexPathChangeSet(moveIndexPaths: [IndexPathMove(fromIndexPath: IndexPath(row: 0, section: 0),
                                                                toIndexPath: IndexPath(row: 1, section: 0))])
        XCTAssertTrue(sut.hasUpdates)
    }

    // MARK: Helpers

    private func createBasicIndexPathChangeSet() -> IndexPathChangeSet {
        let sut = IndexPathChangeSet(insertIndexPaths: inserts,
                                     deleteIndexPaths: deletes,
                                     updateIndexPaths: updates,
                                     moveIndexPaths: moves)
        return sut
    }

    private func createAnotherBasicIndexPathChangeSet() -> IndexPathChangeSet {
        let otherInserts = [IndexPath(row: 0, section: 1)]
        let sut = IndexPathChangeSet(insertIndexPaths: otherInserts,
                                     deleteIndexPaths: deletes,
                                     updateIndexPaths: updates,
                                     moveIndexPaths: moves)
        return sut
    }

}
