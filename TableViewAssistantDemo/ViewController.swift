//
//  ViewController.swift
//  TableViewAssistantDemo
//
//  Created by Ben Davis on 19/01/2019.
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

final class ViewController: UIViewController {

    static let numberOfInitialSections = 3
    var numberOfInitialSections: Int { return ViewController.numberOfInitialSections }

    static let numberOfInitialRows = 3
    var numberOfInitialRows: Int { return ViewController.numberOfInitialRows }

    private static let reuseId = "cell"
    let tableView: UITableView = {
        let result = UITableView()
        result.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        return result
    }()

    var tableViewAssistant: TableViewUpdateAssistant<RowModel>!

    var rowData: [[RowModel]] = generateInitialData()

    private static func generateInitialData() -> [[RowModel]] {
        return (0..<numberOfInitialSections).map { _ in
            (0..<numberOfInitialRows).map { _ in RowModel() }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewAssistant = TableViewUpdateAssistant(tableView: tableView,
                                                      originalModel: rowData)
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startIncrementalRandomUpdates()
    }

    private func startIncrementalRandomUpdates() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.doSomeRandomChanges()
            self.startIncrementalRandomUpdates()
        }
    }

    private func doSomeRandomChanges() {
        for _ in 0..<((numberOfInitialRows*numberOfInitialSections)/2) {
            self.doRandomTableViewChange()
        }
        self.updateTableView()
    }

    private func doRandomTableViewChange() {
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
        let insertSectionIndex = Int.random(in: (0..<rowData.count))
        var row = rowData.remove(at: insertSectionIndex)
        let insertIndex = row.count > 0 ? Int.random(in: (0..<row.count)) : 0
        row.insert(newModel, at: insertIndex)
        rowData.insert(row, at: insertSectionIndex)
    }

    private func doRandomDelete() {
        let deleteSectionIndex = Int.random(in: (0..<rowData.count))
        var row = rowData.remove(at: deleteSectionIndex)
        guard row.count > 0 else {
            rowData.insert(row, at: deleteSectionIndex)
            doRandomInsert()
            return
        }
        let deleteIndex = Int.random(in: (0..<row.count))
        row.remove(at: deleteIndex)
        rowData.insert(row, at: deleteSectionIndex)
    }

    private func doRandomMove() {
        let fromSectionIndex = Int.random(in: (0..<rowData.count))
        var fromRow = rowData.remove(at: fromSectionIndex)
        guard fromRow.count > 0 else {
            rowData.insert(fromRow, at: fromSectionIndex)
            return
        }
        let fromIndex = Int.random(in: (0..<fromRow.count))

        let element = fromRow.remove(at: fromIndex)
        rowData.insert(fromRow, at: fromSectionIndex)

        let toSectionIndex = Int.random(in: (0..<rowData.count))
        var toRow = rowData.remove(at: toSectionIndex)
        let toIndex = (toRow.count > 0) ? Int.random(in: (0..<toRow.count)) : 0

        toRow.insert(element, at: toIndex)
        rowData.insert(toRow, at: toSectionIndex)
    }

    private func doRandomReload() {
        let sectionIndex = Int.random(in: (0..<rowData.count))
        var row = rowData.remove(at: sectionIndex)
        guard row.count > 0 else {
            rowData.insert(row, at: sectionIndex)
            return
        }
        let index = Int.random(in: (0..<row.count))
        var element = row.remove(at: index)
        element.color = UIColor.random()
        row.insert(element, at: index)
        rowData.insert(row, at: sectionIndex)
    }

    private func updateTableView() {
        tableViewAssistant.applyUpdatesToTableView(with: rowData)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return rowData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.reuseId, for: indexPath)
        let data = rowData[indexPath.section][indexPath.row]
        cell.textLabel?.text = "\(data.id)"
        cell.contentView.backgroundColor = data.color
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section: \(section)"
    }
}
