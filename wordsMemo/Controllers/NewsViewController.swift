import Foundation
import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    @IBOutlet private weak var collectionview: UICollectionView!
    private var apiManager = ApiManager()
    private var newsInfos = [NewsModel?]()
    private var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Actualités"
        navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 25)!]
        apiManager.delegate = self //上に書く
        apiManager.performRequest()
        collectionview.delegate = self
        collectionview.dataSource = self
        
        let nib = UINib(nibName: "NewsCollectionViewCell", bundle: nil)
        collectionview.register(nib, forCellWithReuseIdentifier: "collectionCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        collectionview.collectionViewLayout = flowLayout
        indicatorSetup()
        start()
    }
    
    private func indicatorSetup() {
        indicator.center = view.center
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = #colorLiteral(red: 0, green: 0.6113008261, blue: 0.5758315325, alpha: 0.8470000029)
        view.addSubview(indicator)
    }
    private func start() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
    }
    
}

extension NewsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! NewsCollectionViewCell
        //違うところに書きたい
        cell.layer.cornerRadius = 15
        cell.layer.shadowOpacity = 0.4
        cell.layer.shadowRadius = 12
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 8, height: 8)
        
        cell.sourceLabel.text = newsInfos[indexPath.row]?.publisher
        cell.titleLabel.text = newsInfos[indexPath.row]?.titleName
        cell.publishedTitle.text = newsInfos[indexPath.row]?.publishAt
        if let url = URL(string: newsInfos[indexPath.row]?.photoUrl ?? "") {
            do {
                let data = try Data(contentsOf: url)
                if let backImage = UIImage(data: data) {
                   let effect = darken(image: backImage, level: 0.5)
                   cell.imageView.image = effect
                }

                cell.imageView!.contentMode = .scaleAspectFill
            } catch let err {
                cell.backgroundColor = #colorLiteral(red: 0, green: 0.6113008261, blue: 0.5758315325, alpha: 0.8470000029)
                print("Error : \(err.localizedDescription)")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: Util.returnDisplaySize().width - 20, height: 150)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let resultsfield = newsInfos[indexPath.row]
        guard let webPage = resultsfield?.url else { return }
        let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
        safariVC.modalPresentationStyle = .formSheet
        present(safariVC, animated: true, completion: nil)
        
    }
    
    private func darken(image:UIImage, level:CGFloat) -> UIImage{
        // 一時的な暗くするようの黒レイヤ
        let frame = CGRect(origin:CGPoint(x:0,y:0),size:image.size)
        let tempView = UIView(frame:frame)
        tempView.backgroundColor = UIColor.black
        tempView.alpha = level
        // 画像を新しいコンテキストに描画する
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        image.draw(in: frame)
        // コンテキストに黒レイヤを乗せてレンダー
        context!.translateBy(x: 0, y: frame.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.clip(to: frame, mask: image.cgImage!)
        tempView.layer.render(in: context!)
        
        let imageRef = context!.makeImage()
        let toReturn = UIImage(cgImage:imageRef!)
        UIGraphicsEndImageContext()
        return toReturn
        
    }
        
}

extension NewsViewController: apiDelegate {
    //要らない気がする
    func jsonData(_ newsInfo: NewsData) {
        newsInfos.removeAll()
        
        for article in newsInfo.articles {
            
            let titleName = article.title
            let photoUrl = article.urlToImage
            let publisher = article.source.name
            let publishedAt = article.publishedAt
            let url = article.url
            
            let newsData = NewsModel(publisher: publisher, titleName: titleName, photoUrl: photoUrl, publishAt: publishedAt, url: url)
            self.newsInfos.append(newsData)
        }
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.collectionview.reloadData()
        }
    }
}

class Util: NSObject {
    
    class func returnDisplaySize() -> CGSize {
        let displaySize = UIScreen.main.bounds.size
        
        return displaySize
    }
}
