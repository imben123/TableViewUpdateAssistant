# TableViewUpdateAssistant
Utility to compute the differences between two models representing table view rows &amp; sections, and apply them to a table view.

## Demo app
The repository contains an app target with a simple view controller demonstrating the table view updates.
![Demo GIF](/../master/table-view-updates.gif?raw=true)

## Utility Objects

### `IndexPathChangeSet`
This struct represents the computed diff between two sets of elements.

It contains
* An array of insert index paths
* An array of delete index paths
* An array of update index paths
* An array of move pairs of index paths

### `IndexPathChangeSetBuilder`

### `TableViewUpdateAssistant`
