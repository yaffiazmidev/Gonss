import Foundation
import UIKit

class BalancePopView : UIView,UIScrollViewDelegate {
    
    let scrollowView = UIScrollView()
    let  pageControl = UIPageControl()
    let btn = UIButton()
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(hexString: "#000000", alpha: 0.5)
         
        setupUI()
    }
    
    func setupUI(){
        
        let bgView = UIView()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .white
        addSubview(bgView)
        bgView.anchors.height.equal(480)
        bgView.anchors.edges.pin(axis: .horizontal)
        bgView.anchors.bottom.pin()
        
        scrollowView.delegate = self
        scrollowView.isPagingEnabled = true
        scrollowView.showsHorizontalScrollIndicator = false
        scrollowView.bounces = false
        bgView.addSubview(scrollowView)
        scrollowView.anchors.top.pin(inset: 41)
        scrollowView.anchors.height.equal(190+109)
        scrollowView.anchors.edges.pin(axis: .horizontal)
         
        let contentView = UIStackView()
        scrollowView.addSubview(contentView)
        contentView.anchors.edges.pin()
         
        contentView.alignment = .fill
        contentView.distribution = .fillEqually
        
        let infoArr = [["title":"Selamat datang di balance","detail":"Tujuan utama Anda untuk mengelola hadiah, Koin, dan transaksi di KipasKipas.","img":"img-balance-guide1"],
                       ["title":"Cek hadiah dengan mudah","detail":"Temukan hadiahmu dari LIVE, Creator Fund, Subscription dan lainnya.","img":"img-balance-guide2"],
                       ["title":"Atur Koinmu","detail":"Gunakan koin untuk mendukung konten dari kreator LIVE dengan Gift, atau promosikan video mu.","img":"img-balance-guide3"]]
        
        infoArr.enumerated().forEach { (index,info) in
            let subView = getSubContentView(index,info)
            contentView.addArrangedSubview(subView)
            subView.anchors.width.equal(anchors.width)
            subView.anchors.height.equal(scrollowView.anchors.height)
        }
    
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = UIColor(hexString: "#A2A3A6")
        pageControl.contentHorizontalAlignment = .center
        addSubview(pageControl)
        pageControl.anchors.centerX.align() 
        pageControl.anchors.bottom.pin(inset: 112)
        pageControl.anchors.width.equal(280)
        pageControl.anchors.height.equal(22)
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        
       
        btn.layer.cornerRadius = 8
        btn.setTitle("Selanjutnya")
        btn.titleLabel?.font = .roboto(.medium, size: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .watermelon
        addSubview(btn)
        btn.anchors.top.equal(pageControl.anchors.bottom,constant: 21)
        btn.anchors.edges.pin(insets: 33, axis: .horizontal)
        btn.anchors.height.equal(40)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        
    }
    
    func getSubContentView( _ index: Int , _ info : [String:String] ) -> UIView {
         let view = UIView()
        
         let imageV = UIImageView()
        imageV.image = .set(info["img"]!)
        view.addSubview(imageV)
        imageV.anchors.top.pin()
        imageV.anchors.width.equal(256)
        imageV.anchors.height.equal(190)
        imageV.anchors.centerX.align()
        
        let titleL = UILabel()
        titleL.textColor = .black
        titleL.font = .roboto(.bold, size: 22)
        titleL.text = info["title"]
        view.addSubview(titleL)
        titleL.anchors.top.equal(imageV.anchors.bottom,constant: 0)
        titleL.anchors.centerX.align()
        
        let detailL = UILabel()
        detailL.numberOfLines = 0
        detailL.textColor = .black
        detailL.font = .roboto(.regular, size: 14)
        detailL.attributedText = setLineSpacing(str: info["detail"]!,spacing: 6)
        detailL.textAlignment = .center
        view.addSubview(detailL)
        detailL.anchors.top.equal(titleL.anchors.bottom,constant: 10)
        detailL.anchors.edges.pin(insets: 43, axis: .horizontal)
        detailL.anchors.height.greaterThanOrEqual(60)
        
        detailL.anchors.bottom.pin(inset: 3)
         
          
        return view
    }
    
    
    @objc func btnAction(_ button: UIButton){
        if pageControl.currentPage == 2 {
            UserDefaults.standard.setValue(true, forKey: "BalancePopView")
            self.removeFromSuperview()
        }else{
            pageControl.currentPage = pageControl.currentPage + 1
            btn.setTitle(pageControl.currentPage == 2 ? "Mulai" : "Selanjutnya")
            let offsetX = scrollowView.frame.size.width * CGFloat(pageControl.currentPage)
            scrollowView.setContentOffset(CGPoint(x: offsetX , y: 0), animated: true)
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        pageControl.currentPage =  Int(offsetX / scrollView.frame.size.width)
        btn.setTitle(pageControl.currentPage == 2 ? "Mulai" : "Selanjutnya")
    }
    
    
    func setLineSpacing(str:String , spacing: CGFloat) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, str.count))
        return attributedString
    }
}


