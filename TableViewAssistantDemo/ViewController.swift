//
//  ViewController.swift
//  TableViewAssistantDemo
//
//  Created by Ben Davis on 19/01/2019.
//  Copyright © 2019 Ben Davis Apps. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private static let reuseId = "cell"
    let tableView: UITableView = {
        let result = UITableView()
        result.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        return result
    }()

    var tableViewAssistant: TableViewUpdateAssistant<RowModel>!
    let rowDataSource = RowDataSource(numberOfInitialSections: 3, numberOfInitialRows: 3)
    var rowData: [[RowModel]] = [[],[],[]]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewAssistant = TableViewUpdateAssistant(tableView: tableView, originalModel: rowData)
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
        rowData = rowDataSource.fetchNewRowData()
        updateTableView()
    }

    private func updateTableView() {
        tableViewAssistant.applyUpdatesToTableView(with: rowData)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return rowData.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section: \(section)"
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
}
