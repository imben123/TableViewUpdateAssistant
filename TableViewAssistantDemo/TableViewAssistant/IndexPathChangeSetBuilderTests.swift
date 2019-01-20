//
//  IndexPathChangeSetBuilderTests.swift
//  TableViewAssistantDemoTests
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import XCTest
@testable import TableViewAssistantDemo

final class IndexPathChangeSetBuilderTests: XCTestCase {

    private typealias Model = DummyModel

    private final class IdentifiableModel: Model, Identifiable {
        let id: UUID
        init(id: UUID = UUID()) {
            self.id = id
        }
    }

    private let obj1 = Model()
    private let obj2 = Model()
    private let obj3 = Model()
    private let obj4 = Model()

    func test_initialArraysAreEmpty() {
        let sut = IndexPathChangeSetBuilder<Model>()
        XCTAssert(sut.originalTree.isEmpty)
        XCTAssert(sut.updatedTree.isEmpty)
    }

    func test_initiallyOutputsEmptyChangeSet() {
        let sut = IndexPathChangeSetBuilder<Model>()
        let expected = IndexPathChangeSet()
        let result = sut.build()
        XCTAssertEqual(result, expected)
    }

    func test_forEquatableElements_equalityOperatorIsUsed() {
        let sut = IndexPathChangeSetBuilder<String>()
        let obj1 = "hello"
        let obj2 = "world"

        XCTAssertTrue(sut.equalityComparator(obj1, obj1))
        XCTAssertFalse(sut.equalityComparator(obj1, obj2))
    }

    func test_forIdentifiableTypeElements_idsAreComparedForIdentityComparator() {
        let sut = IndexPathChangeSetBuilder<IdentifiableModel>()
        let obj1 = IdentifiableModel()
        let obj2 = IdentifiableModel(id: obj1.id)
        let obj3 = IdentifiableModel()

        XCTAssertTrue(sut.identityComparator(obj1, obj2))
        XCTAssertFalse(sut.equalityComparator(obj1, obj3))
    }

    func test_forReferenceTypeElements_identityOperatorIsUsed() {
        let sut = IndexPathChangeSetBuilder<NSObject>()
        let obj1 = NSObject()
        let obj2 = NSObject()

        XCTAssertTrue(sut.identityComparator(obj1, obj1))
        XCTAssertFalse(sut.identityComparator(obj1, obj2))
    }

    func test_forHashableTypeElements_objectsHashIsUsedToComputeDiffs() {

        let sut = IndexPathChangeSetBuilder<Model>(originalTree: [[obj1, obj2]])

        // When
        obj2.changeContent()

        // Then
        XCTAssertTrue(sut.equalityComparator(obj1, obj1))
        XCTAssertFalse(sut.equalityComparator(obj2, obj2))
    }

    func test_defaultEqualityOperatorIsPreferredOverHashableEqualityOperator_forIdentifiableElements() {
        let sut = IndexPathChangeSetBuilder<IdentifiableModel>()
        let obj1 = IdentifiableModel()
        let obj2 = IdentifiableModel(id: obj1.id)

        // When we don't set the original tree
        // (i.e. previous object hashes are not recorded)
        obj2.changeContent()

        // Then
        XCTAssertTrue(sut.equalityComparator(obj1, obj1))
        XCTAssertTrue(sut.equalityComparator(obj2, obj2))
    }

    func test_findsInserts() {
        let sut = IndexPathChangeSetBuilder<Model>(originalTree: [[obj1]])
        sut.updatedTree = [[obj1, obj2], [obj3]]
        let result = sut.build()
        let expected = IndexPathChangeSet(insertIndexPaths: [
            IndexPath(item: 1, section: 0),
            IndexPath(item: 0, section: 1),
        ])
        XCTAssertEqual(result, expected)
    }

    func test_findsDeletes() {
        let sut = IndexPathChangeSetBuilder<Model>(originalTree: [[obj1, obj2], [obj3]])
        sut.updatedTree = [[obj1]]
        let result = sut.build()
        let expected = IndexPathChangeSet(deleteIndexPaths: [
            IndexPath(item: 1, section: 0),
            IndexPath(item: 0, section: 1),
        ])
        XCTAssertEqual(result, expected)
    }

    func test_findMoves() {
        let sut = IndexPathChangeSetBuilder<Model>(originalTree: [[obj1, obj2, obj3, obj4]])
        sut.updatedTree = [[obj2, obj1, obj3], [obj4]]
        let result = sut.build()
        let expected = IndexPathChangeSet(moveIndexPaths: [
            IndexPathMove(fromIndexPath: IndexPath(row: 1, section: 0),
                          toIndexPath: IndexPath(row: 0, section: 0)),
            IndexPathMove(fromIndexPath: IndexPath(row: 0, section: 0),
                          toIndexPath: IndexPath(row: 1, section: 0)),
            IndexPathMove(fromIndexPath: IndexPath(row: 3, section: 0),
                          toIndexPath: IndexPath(row: 0, section: 1))
            ])
        XCTAssertEqual(result, expected)
    }

    func test_findReloads() {
        let sut = IndexPathChangeSetBuilder<Model>(originalTree: [[obj1, obj2], [obj3]])
        obj2.changeContent()
        sut.updatedTree = [[obj1, obj2], [obj3]]

        let result = sut.build()
        let expected = IndexPathChangeSet(updateIndexPaths: [
            IndexPath(item: 1, section: 0),
            ])
        XCTAssertEqual(result, expected)
    }

    func test_findReloadsOfMovedRows() {
        let sut = IndexPathChangeSetBuilder<Model>(originalTree: [[obj1, obj2], [obj3]])
        obj2.changeContent()
        sut.updatedTree = [[obj2, obj1], [obj3]]

        let result = sut.build()
        let expected = [IndexPath(item: 1, section: 0)]
        XCTAssertEqual(result.updateIndexPaths, expected)
    }
}
