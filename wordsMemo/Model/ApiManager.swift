import Foundation

protocol apiDelegate: AnyObject {
    func jsonData(_ newsInfo: NewsData)
}

struct ApiManager {
    
    weak var delegate: apiDelegate?
    
    func performRequest() {
        guard let newsURL = URL(string: "https://newsapi.org/v2/top-headlines?country=fr&apiKey=6b52721a8f3646f3915d33c06a28157a") else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: newsURL) { (data, response, error) in
            if error != nil {
                print("タスク失敗")
                return
            }
            if let safeData = data {
                let safeNews = parseJSON(safeData)
                delegate?.jsonData(safeNews!)
            }
        }
        
        task.resume()
    }
    
    func parseJSON(_ newsData: Data) -> NewsData? {
        
        let decoder = JSONDecoder()
        
        do {
            let newsInfo = try decoder.decode(NewsData.self, from: newsData)
            return newsInfo
        } catch  {
            print("パースに失敗しました")
            return nil
        }
    }
    
}
