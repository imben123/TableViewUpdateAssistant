//
//  IndexPathChangeSetBuilder.swift
//  TableViewAssistantDemo
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import Foundation

protocol Identifiable {
    associatedtype T: Equatable
    var id: T { get }
}

class IndexPathChangeSetBuilder<T> {

    private(set) var originalTree: [[T]] {
        didSet { updateTreeHashesIfHashableObjects() }
    }
    var updatedTree : [[T]] = []
    var equalityComparator: (_ old: T, _ new: T) -> Bool = { _,_ in return false }
    var identityComparator: (T, T) -> Bool = { _,_ in return false }

    // MARK: -

    /// Used for hash based equality comparator
    private var originalTreeHashes: [(element: T, hash: Int)]?

    private func updateTreeHashesIfHashableObjects() {
        if let self = self as? IndexPathChangeSetBuilderForHashableObjects {
            self.updateTreeHashes()
        }
    }

    // MARK: -

    init(originalTree: [[T]] = []) {
        self.originalTree = originalTree

        // Set initial hashes (didSet not called during init)
        updateTreeHashesIfHashableObjects()
        
        setupDefaultComparatorImplementations()
    }

    private func setupDefaultComparatorImplementations() {
        // The order of this initialisation sets the precedence of the default identity/equality operators
        if let self = self as? IndexPathChangeSetBuilderForEquatableObjects {
            self.addDefaultEqualityComparator()
        }
        if let self = self as? IndexPathChangeSetBuilderForIdentifiableObjects {
            self.addIdBasedIdentityComparator()
        } else if let self = self as? IndexPathChangeSetBuilderForReferenceTypeObjects {
            self.addReferenceBasedIdentityComparator()
            if let self = self as? IndexPathChangeSetBuilderForHashableObjects {
                self.addHashBasedEqualityComparator()
            }
        }
    }

    // MARK: - Compute the change set

    func build() -> IndexPathChangeSet {
        defer { originalTree = updatedTree }
        return IndexPathChangeSet(insertIndexPaths: findInserts(),
                                  deleteIndexPaths: findDeletes(),
                                  updateIndexPaths: findUpdates(),
                                  moveIndexPaths: findMoves())
    }

    private func findInserts() -> [IndexPath] {
        return findElements(in: updatedTree, whichDoNotExistIn: originalTree)
    }

    private func findDeletes() -> [IndexPath] {
        return findElements(in: originalTree, whichDoNotExistIn: updatedTree)
    }

    private func findUpdates() -> [IndexPath] {
        let oldTree = enumerateTree(originalTree)
        let result = oldTree.filter(elementNeedsUpdate).map { $0.indexPath }
        return result
    }

    private func findMoves() -> [IndexPathMove] {
        let enumeratedTree = enumerateTree(updatedTree)

        var result: [IndexPathMove] = []
        for (newIndexPath, element) in enumeratedTree {

            if let oldIndexPath = indexPath(of: element, in: originalTree), oldIndexPath != newIndexPath {

                result.append(IndexPathMove(fromIndexPath: oldIndexPath,
                                            toIndexPath: newIndexPath))
            }
        }
        return result
    }

    // MARK: - Helpers

    private func findElements(in tree: [[T]], whichDoNotExistIn otherTree: [[T]]) -> [IndexPath] {
        let enumeratedTree = enumerateTree(tree)
        let elementsToExclude = otherTree.flatMap({ $0 })

        let inserts = enumeratedTree.filter {
            !isEnumeratedElementInSet($0, set: elementsToExclude)
        }
        return inserts.map { $0.indexPath }
    }

    private func isEnumeratedElementInSet(_ enumeratedElement: (indexPath: IndexPath, element: T), set: [T]) -> Bool {
        return set.contains(where: { identityComparator($0, enumeratedElement.element) })
    }

    private func indexPath(of element: T, in tree: [[T]]) -> IndexPath? {
        return enumerateTree(tree).first(where: { identityComparator($1, element) })?.indexPath
    }

    private func elementNeedsUpdate(indexPath: IndexPath, element: T) -> Bool {
        let newTree = enumerateTree(updatedTree)
        let newValue = newTree.first(where: { identityComparator($0.element, element) })
        guard let (_, newElement) = newValue else {
            return false
        }
        return !equalityComparator(element, newElement)
    }

    private func enumerateTree(_ tree: [[T]]) -> [(indexPath: IndexPath, element: T)] {
        return tree.enumerated().flatMap {
            enumerateSection($0, elements: $1)
        }
    }

    private func enumerateSection(_ section: Int, elements: [T]) -> [(indexPath: IndexPath, element: T)] {
        return elements.enumerated().map {
            (indexPath: IndexPath(row: $0, section: section), element: $1)
        }
    }
}

// MARK: - Additional setup methods only available with particular generic constraints

private protocol IndexPathChangeSetBuilderForEquatableObjects {
    func addDefaultEqualityComparator()
}

private protocol IndexPathChangeSetBuilderForHashableObjects {
    func updateTreeHashes()
    func addHashBasedEqualityComparator()
}

private protocol IndexPathChangeSetBuilderForIdentifiableObjects {
    func addIdBasedIdentityComparator()
}

private protocol IndexPathChangeSetBuilderForReferenceTypeObjects {
    func addReferenceBasedIdentityComparator()
}

// MARK: - Default equality and identity comparators

extension IndexPathChangeSetBuilder: IndexPathChangeSetBuilderForEquatableObjects where T: Equatable {

    // Most common implementations will want to compare instances of immutable models
    fileprivate func addDefaultEqualityComparator() {
        equalityComparator = { $0 == $1 }
    }
}

extension IndexPathChangeSetBuilder: IndexPathChangeSetBuilderForIdentifiableObjects where T: Identifiable {

    /// For immutable models, using an ID property is the easiest way to compare identity
    fileprivate func addIdBasedIdentityComparator() {
        identityComparator = { $0.id == $1.id }
    }
}

extension IndexPathChangeSetBuilder: IndexPathChangeSetBuilderForReferenceTypeObjects where T: AnyObject {

    /// In some cases you may use mutable classes. In this case identity can be compared by reference
    fileprivate func addReferenceBasedIdentityComparator() {
        identityComparator = { $0 === $1 }
    }
}

extension IndexPathChangeSetBuilder: IndexPathChangeSetBuilderForHashableObjects where T: Hashable & AnyObject {

    /// When using mutable classes you cannot use the "==" comparator (as the old/new models are the same)
    /// object now. Instead we support caching the hashes of the models to detect updates.
    fileprivate func addHashBasedEqualityComparator() {
        equalityComparator = { [weak self] old, new in
            let previousHash = self?.getPreviousHash(of: old)
            return previousHash == new.hashValue
        }
    }

    fileprivate func updateTreeHashes() {
        originalTreeHashes = originalTree.flatMap({ $0 }).map({ (element: $0, hash: $0.hashValue) })
    }

    private func getPreviousHash(of element: T) -> Int? {
        return originalTreeHashes?.first(where: { $0.element === element })?.hash
    }
}
