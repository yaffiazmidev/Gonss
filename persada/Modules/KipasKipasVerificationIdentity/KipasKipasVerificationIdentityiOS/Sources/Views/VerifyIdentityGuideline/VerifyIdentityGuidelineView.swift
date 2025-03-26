import UIKit
import KipasKipasShared

struct GuidelineItem {
    let title: String
    let titleIcon: UIImage?
    let image: UIImage?
    let points: [String]
}

class VerifyIdentityGuidelineView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var guidelines: [GuidelineItem] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func setupComponent() {
        backgroundColor = .white
        overrideUserInterfaceStyle = .light
        containerView.backgroundColor = .white
        guidelines = getGuidelines()
        configureUI()
    }
}

extension VerifyIdentityGuidelineView {
    private func configureUI() {
        pageControl.numberOfPages = guidelines.count
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNibCell(VerifyIdentityGuidelineCVC.self)
    }
}

extension VerifyIdentityGuidelineView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guidelines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: VerifyIdentityGuidelineCVC  = collectionView.dequeueReusableCell(at: indexPath)
        cell.configure(with: guidelines[indexPath.item])
        return cell
    }
}

extension VerifyIdentityGuidelineView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: frame.width, height: collectionView.frame.height)
    }
}

extension VerifyIdentityGuidelineView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        
        if pageControl.currentPage != currentPage {
            pageControl.currentPage = currentPage
        }
    }
}

private extension VerifyIdentityGuidelineView {
    private func getGuidelines() -> [GuidelineItem] {
        return [
            GuidelineItem(
                title: "Contoh yang baik",
                titleIcon: .iconCircleCheckGreen,
                image: UIImage.get(.img_ktpwarna_blurred),
                points: [
                    "Resolusi tinggi",
                    "Informasi yang lengkap",
                    "Berwarna",
                    "Semua informasi yang dibutuhkan (nama, tangggal lahir, nomor identitas, alamat) terlihat jelas."
                ]
            ),
            GuidelineItem(
                title: "Foto Blur",
                titleIcon: .iconCircleCloseFillRed,
                image: UIImage.get(.img_ktpwarna_blurred),
                points: [
                    "Gunakan foto dengan resolusi tinggi",
                    "Foto identitas yang lengkap",
                    "Foto berwarna",
                    "Semua informasi yang dibutuhkan (nama, tangggal lahir, nomor identitas, alamat) terlihat jelas."
                ]
            ),
            GuidelineItem(
                title: "Foto dengan kualitas rendah",
                titleIcon: .iconCircleCloseFillRed,
                image: UIImage.get(.img_ktpwarna_dark),
                points: [
                    "Ambil foto dengan cahaya yang cukup.",
                    "Hindari pantulan dan silau."
                ]
            ),
            GuidelineItem(
                title: "Dokumen yang tidak didukung",
                titleIcon: .iconCircleCloseFillRed,
                image: UIImage.get(.img_ktpwarna_notsupport),
                points: ["Dokumen yang tidak kami terima: Sertifikat Kelahiran, Identitas Perusahaan, Kartu Kredit, Kartu Pelajar, Visa, Screenshots atau foto dari layar handphone."]
            ),
            GuidelineItem(
                title: "Foto yang tidak lengkap",
                titleIcon: .iconCircleCloseFillRed,
                image: UIImage.get(.img_ktpwarna_cropped),
                points: [
                    "Foto harus menyertakan seluruh dokumen.",
                    "Jangan menutupi bagian dari dokumen dengan tangan."
                ]
            )
        ]
    }
}
