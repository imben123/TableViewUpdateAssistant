//
//  TableViewUpdateAssistant.swift
//  TableViewAssistantDemo
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import UIKit

protocol UpdatableTableView {

    // Allows multiple insert/delete/reload/move calls to be animated simultaneously. Nestable.
    @available(iOS 11.0, *)
    func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?)

    // Use -performBatchUpdates:completion: instead of these methods, which will be deprecated in a future release.
    func beginUpdates()
    func endUpdates()

    // ----------------------------------------------------------------------------------
    // Not supported (maybe add support in future)
    // func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
    // func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
    // func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation)
    // func moveSection(_ section: Int, toSection newSection: Int)
    // ----------------------------------------------------------------------------------

    func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
}
extension UITableView: UpdatableTableView {}

class TableViewUpdateAssistant<T> {

    let tableView: UpdatableTableView

    private let builder: IndexPathChangeSetBuilder<T>
    
    var equalityComparator: (T, T) -> Bool {
        set { builder.equalityComparator = newValue }
        get { return  builder.equalityComparator }
    }
    var identityComparator: (T, T) -> Bool {
        set { builder.identityComparator = newValue }
        get { return  builder.identityComparator }
    }

    init(tableView: UpdatableTableView, originalModel: [[T]] = [[]]) {
        self.tableView = tableView
        self.builder = IndexPathChangeSetBuilder<T>(originalTree: originalModel)
    }

    func applyUpdatesToTableView(with updatedModel: [[T]]) {

        builder.updatedTree = updatedModel
        let changeSet = builder.build()

        guard changeSet.hasUpdates else {
            return
        }

        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates({
                self.performInsertsDeletesAndMoves(changeSet: changeSet)
            }, completion: nil)
            tableView.performBatchUpdates({
                self.performReloads(changeSet: changeSet)
            }, completion: nil)
        } else {
            tableView.beginUpdates()
            performInsertsDeletesAndMoves(changeSet: changeSet)
            tableView.endUpdates()
            
            tableView.beginUpdates()
            performReloads(changeSet: changeSet)
            tableView.endUpdates()
        }
    }

    private func performInsertsDeletesAndMoves(changeSet: IndexPathChangeSet) {

        if changeSet.deleteIndexPaths.count > 0 {
            tableView.deleteRows(at: changeSet.deleteIndexPaths, with: .automatic)
        }

        if changeSet.insertIndexPaths.count > 0 {
            tableView.insertRows(at: changeSet.insertIndexPaths, with: .automatic)
        }

        for indexPathMove in changeSet.moveIndexPaths {
            tableView.moveRow(at: indexPathMove.fromIndexPath, to: indexPathMove.toIndexPath)
        }
    }

    private func performReloads(changeSet: IndexPathChangeSet) {

        if changeSet.updateIndexPaths.count > 0 {
            tableView.reloadRows(at: changeSet.correctedUpdateIndexPaths, with: .automatic)
        }
    }
}
