//
//  Created by BK @kitabisa.
//

import UIKit

// MARK: [KBPL] Add haptic feedback when `didSelect` occured
public protocol KBTabViewDelegate: AnyObject {
    func didSelectTabView(_ item: any KBTabViewItemable, at indexPath: IndexPath)
    func shouldSelectTabView(_ item: any KBTabViewItemable, at indexPath: IndexPath) -> Bool
}

internal class KBTabViewSelectionConfigurator<Item: KBTabViewItemable, Cell: KBTabViewBaseCell>: NSObject, UICollectionViewDelegate {
    
    private var oldSelectedIndex: IndexPath
    
    /*
     Used for resetting items state.
     This variable only assigned once.
     */
    var oldItems: [Item] = [] {
        didSet {
            reconfigureItems(oldItems, at: oldSelectedIndex)
        }
    }
    
    private var reconfiguredItems: [Item] = []
    
    weak var delegate: KBTabViewDelegate?
    
    init(oldSelectedIndex: IndexPath) {
        self.oldSelectedIndex = oldSelectedIndex
    }
    
    private func reconfigureItems(_ items: [Item], at indexPath: IndexPath) {
        // Set the `isSelected` value at particular index of items.
        var items = items
        items[indexPath.item].id = UUID().uuidString
        items[indexPath.item].isSelected = shouldSelectItem(item: items[indexPath.item], at: indexPath)
        
        reconfiguredItems.removeAll()
        reconfiguredItems.append(contentsOf: items)
    }
    
    private func reconfigureSelectedCell(_ collectionView: UICollectionView, at newIndex: IndexPath) {
        // Select new cell
        let newSelectedItem = reconfiguredItems[newIndex.item]
        let newSelectedCell = cell(collectionView, at: newIndex)
        newSelectedCell?.setSelected = newSelectedItem.isSelected
        delegate?.didSelectTabView(newSelectedItem, at: newIndex)
        
        DispatchQueue.main.async {
            // collectionView.collectionViewLayout.prepare()
            collectionView.scrollToItem(at: newIndex, at: .centeredHorizontally, animated: true)
            // collectionView.collectionViewLayout.invalidateLayout()
        }
        
        // Unselect old selected cell
        guard shouldSelectItem(item: newSelectedItem, at: newIndex) else {
            reconfigureItems(oldItems, at: oldSelectedIndex)
            return
        }
        
        let oldSelectedCell = cell(collectionView, at: oldSelectedIndex)
        oldSelectedCell?.setSelected = false
        oldSelectedIndex = newIndex
    }
    
    func setBadgeValue(_ count: Int, at index: Int) {
        if reconfiguredItems[safe: index] != nil {
            reconfiguredItems[index].badgeValue = String(count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // guard let cell = cell(collectionView, at: indexPath) else { return }
        
        // guard selectionEnabled() && !cell.setSelected else { return }
        guard selectionEnabled() else { return }
        
        reconfigureItems(oldItems, at: indexPath)
        reconfigureSelectedCell(collectionView, at: indexPath)
    }
    
    private func selectionEnabled() -> Bool {
        return oldItems.allSatisfy { $0.isLoading == false }
    }
    
    private func shouldSelectItem(item: any KBTabViewItemable, at indexPath: IndexPath) -> Bool {
        guard let shouldSelectItem = delegate?.shouldSelectTabView(item, at: indexPath) else {
            return false
        }
        return shouldSelectItem
    }
    /*
     Used for maintaining the selected state of a particular cell.
     */
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = reconfiguredItems[safe: indexPath.item] else { return }
        
        let willBeDisplayedCell = cell as? Cell
        willBeDisplayedCell?.setSelected = !item.isLoading && item.isSelected
        willBeDisplayedCell?.view.isLoading = item.isLoading
        
        // Need to layout immediately because sometime frame's returning 0
        if cell is KBTabViewSegmentedCell {
            cell.layoutIfNeeded()
        }
    }
    
    // MARK: Helpers
    private func cell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> Cell? {
        let cell = collectionView.cellForItem(at: indexPath) as? Cell
        return cell
    }
}

private extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
