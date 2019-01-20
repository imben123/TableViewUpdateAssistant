//
//  IndexPathChangeSet.swift
//  TableViewAssistantDemo
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import Foundation

struct IndexPathMove: Equatable {
    let fromIndexPath: IndexPath
    let toIndexPath: IndexPath
}

/// Represents changes of items in a tree of nested array collections.
///
/// This struct is useful for representing all of the changes required to
/// perform animated row operations on a UITableView or a UICollectionView.
struct IndexPathChangeSet: Equatable {

    /// The items that have been added to the tree.
    let insertIndexPaths: [IndexPath]

    /// The items that have been removed from the tree
    let deleteIndexPaths: [IndexPath]

    /// The items that have still exist in the same position but whose content has changed
    let updateIndexPaths: [IndexPath]

    /// The items that have moved from one place in the tree to another
    let moveIndexPaths: [IndexPathMove]

    /// Corrected updates are the index paths of the updates after the inserts/deletes/moves have been applied
    var correctedUpdateIndexPaths: [IndexPath] {
        return self.calculateCorrectedUpdateIndexPaths()
    }

    var hasUpdates: Bool {
        return (insertIndexPaths.count > 0 ||
                deleteIndexPaths.count > 0 ||
                updateIndexPaths.count > 0 ||
                moveIndexPaths.count > 0)
    }

    init(insertIndexPaths: [IndexPath] = [],
         deleteIndexPaths: [IndexPath] = [],
         updateIndexPaths: [IndexPath] = [],
         moveIndexPaths: [IndexPathMove] = []) {
        self.insertIndexPaths = insertIndexPaths
        self.deleteIndexPaths = deleteIndexPaths
        self.updateIndexPaths = updateIndexPaths
        self.moveIndexPaths = moveIndexPaths
    }
}

extension IndexPathChangeSet {
    fileprivate func calculateCorrectedUpdateIndexPaths() -> [IndexPath] {
        return updateIndexPaths.map(applyMovesToIndexPath)
    }

    private func applyMovesToIndexPath(indexPath: IndexPath) -> IndexPath {
        for move in moveIndexPaths {
            if indexPath == move.fromIndexPath {
                return move.toIndexPath
            }
        }
        return indexPath // No move found
    }
}

