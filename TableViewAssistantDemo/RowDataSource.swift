//
//  RowDataSource.swift
//  TableViewAssistantDemo
//
//  Created by Ben Davis on 20/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1),
                       green: CGFloat.random(in: 0...1),
                       blue: CGFloat.random(in: 0...1),
                       alpha: 0.6)
    }
}

struct RowModel: Identifiable, Equatable {

    private static var currentId = 0
    private static func nextId() -> Int {
        defer { currentId += 1 }
        return currentId
    }

    let id: Int
    var color: UIColor

    init(id: Int = nextId(), color: UIColor = .random()) {
        self.id = id
        self.color = color
    }
}

class RowDataSource {

    private var rowData: [[RowModel]]
    private let numberOfInitialSections: Int
    private let numberOfInitialRows: Int

    init(numberOfInitialSections: Int, numberOfInitialRows: Int) {
        self.numberOfInitialSections = numberOfInitialSections
        self.numberOfInitialRows = numberOfInitialRows
        self.rowData = (0..<numberOfInitialSections).map { _ in
            (0..<numberOfInitialRows).map { _ in RowModel() }
        }
    }

    func fetchNewRowData() -> [[RowModel]] {
        for _ in 0..<((numberOfInitialRows*numberOfInitialSections)/2) {
            doRandomRowChange()
        }
        return rowData
    }

    private func doRandomRowChange() {
        let random = Int.random(in: (0..<4))
        if random == 0 {
            if rowData.count > (numberOfInitialRows / 2 * 3) {
                doRandomDelete()
            } else {
                doRandomInsert()
            }
        } else if random == 1 {
            if rowData.count > (numberOfInitialRows / 2) {
                doRandomDelete()
            } else {
                doRandomInsert()
            }
        } else if random == 2 {
            doRandomMove()
        } else if random == 3 {
            doRandomReload()
        }
    }

    private func doRandomInsert() {
        let newModel = RowModel()
        let sectionIndex = Int.random(in: (0..<rowData.count))
        let row = rowData[sectionIndex]
        let rowIndex = row.count > 0 ? Int.random(in: (0..<row.count)) : 0
        rowData[sectionIndex].insert(newModel, at: rowIndex)
    }

    private func doRandomDelete() {
        let sectionIndex = Int.random(in: (0..<rowData.count))
        let row = rowData[sectionIndex]
        guard row.count > 0 else {
            return
        }
        let rowIndex = Int.random(in: (0..<row.count))
        rowData[sectionIndex].remove(at: rowIndex)
    }

    private func doRandomMove() {
        let fromSectionIndex = Int.random(in: (0..<rowData.count))
        let fromRow = rowData[fromSectionIndex]
        guard fromRow.count > 0 else { return }
        let fromRowIndex = Int.random(in: (0..<fromRow.count))

        let element = rowData[fromSectionIndex].remove(at: fromRowIndex)

        let toSectionIndex = Int.random(in: (0..<rowData.count))
        let toRow = rowData[toSectionIndex]
        let toRowIndex = (toRow.count > 0) ? Int.random(in: (0..<toRow.count)) : 0

        rowData[toSectionIndex].insert(element, at: toRowIndex)
    }

    private func doRandomReload() {
        let sectionIndex = Int.random(in: (0..<rowData.count))
        let row = rowData[sectionIndex]
        guard row.count > 0 else { return }
        let rowIndex = Int.random(in: (0..<row.count))
        rowData[sectionIndex][rowIndex].color = .random()
    }
}
