# TableViewUpdateAssistant
Utility to compute the differences between two models representing table view rows &amp; sections, and apply them to a table view.

## Demo app
The repository contains an app target with a simple view controller demonstrating the table view updates.

![Demo GIF](/../master/table-view-updates.gif?raw=true)

## Useage

First you need to create a view model to describe your row data for the table view cells.

It is recommended to use a struct which conforms to `Identifiable` and `Equatable`. This will provide you with default implementations of the equality comparator and identity comparator that support all features.

```swift
struct RowModel: Identifiable, Equatable {
    let id: UUID
    var cellContent: String

    init(id: UUID = UUID(), cellContent: String) {
        self.id = id
        self.cellContent = cellContent
    }
}
```

If you don't need to support table view cell reloads then you can use a class type which conforms to `Equatable`. The `===` comparitor will be used to compare the different rows when computing the table view row updates.

```swift
class RowModel: Equatable {
    var cellContent: String

    init(cellContent: String) {
        self.cellContent = cellContent
    }
}
```

You should then store your row models in a 2D array representing sections and rows.

```swift
var rowData: [[RowModel]]
```

When you need to make changes to the row data you can use now use the `TableViewUpdateAssistant` to compute the row animations.

```swift
// Create a table view update assistant
let tableViewAssistant = TableViewUpdateAssistant(tableView: tableView,
                                                  originalModel: rowData)

// Make changes to your model
let newRowData = ...
newRowData[section][index] = newModel
newRowData[section].insert(newModel, at: index)
newRowData[section].remove(at: index)

// ...or perhaps you get an updated model from an external dependancy.
newRowData = myAPI.fetchNewModel()

// Make sure to give your table view data source the updated model before calling applyUpdatesToTableView
myTableViewDataSource.rowData = newRowData

// Finally use the table view assistant to compute the differences and animate the table view.
tableViewAssistant.applyUpdatesToTableView(with: newRowData)
```

## Utility Objects

#### `IndexPathChangeSet`
This struct represents the computed diff between two sets of elements.

It contains
* An array of insert index paths
* An array of delete index paths
* An array of update index paths (rows that need to be reloaded)
* An array of move pairs of index paths

#### `IndexPathChangeSetBuilder`
Computes the `IndexPathChangeSet` based on the difference of the model objects.

The model objects should be represented as a 2-dimensional array of sections containing row data.

In order to compute the differences it needs to use a equality comparator and a identity comparator. Default implementations of these are given based on the type of the model.

The identity comparator is used to compute inserts, deletes and moves. The equality comparator is used on models that pass the identitiy comparator to determine if the model has changes and therefore needs to have an update (reload).

* Equatable models use the `==` operator as the equality comparator by default.

* If the model conforms to `Identifiable` (i.e. it has an equatable `id` property) then the model's `id` property is compared for the default identity comparator.

* If the model is a class which does not conform to `Identifiable`, then the `===` operator is used as the default identity comparator.

* If the `===` operator is being used as the default identity comparator, then it no longer makes sense to use `==` for equality because it will always return `true` (`===` implies `==`). To determine if an instance of the class has updated the builder will cache hash values of the object and will compare these for the equality comparator.


#### `TableViewUpdateAssistant`
This class wraps the `IndexPathChangeSetBuilder` and will apply the computed change set to a table view instance using the methods listed in the `UpdatableTableView` protocol (`performBatchUpdates`, `insertRows`, `deleteRows`, etc.)
