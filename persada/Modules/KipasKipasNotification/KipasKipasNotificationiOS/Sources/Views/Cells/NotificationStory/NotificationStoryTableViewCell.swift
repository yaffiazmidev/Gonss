import UIKit
import KipasKipasShared
import KipasKipasStoryiOS

class NotificationStoryTableViewCell: UITableViewCell {
    
    lazy var listView: StoryListView = {
        let view = StoryListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = .init(
            active: .init(hexString: "1AE2C8"),
            hasView: .init(hexString: "DDDDDD"),
            live: .primary,
            background: .white,
            text: .black
        )
        
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        listView.myStory = nil
        listView.stories = []
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

private extension NotificationStoryTableViewCell {
    private func configUI() {
        contentView.addSubview(listView)
        listView.anchors.trailing.equal(contentView.anchors.trailing)
        listView.anchors.leading.equal(contentView.anchors.leading)
        listView.anchors.top.equal(contentView.safeAreaLayoutGuide.anchors.top, constant: 16)
        listView.anchors.bottom.equal(contentView.anchors.bottom)
        listView.anchors.height.equal(108)
    }
}
